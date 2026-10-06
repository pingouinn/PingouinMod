import os
import re
from pathlib import Path

# Source directory containing Lua scripts
LUA_DIR = Path("scripts/code")
OUTPUT_FILE = Path("API.md")

# Parsing REGEX patterns for Lua documentation comments
FUNC_REGEX = re.compile(
    r"^(?:local\s+)?function\s+([a-zA-Z0-9_.:]+)\s*\((.*?)\)|"
    r"^([a-zA-Z0-9_.:]+)\s*=\s*function\s*\((.*?)\)"
)
CLASS_REGEX = re.compile(r"^--+[\s*]*@class\s+([a-zA-Z0-9_]+)(?:\s+(.*))?$")
FIELD_REGEX = re.compile(
    r"^--+[\s*]*@field\s+([a-zA-Z0-9_]+)\s+(\S+)(?:\s+(.*))?$"
)
PARAM_REGEX = re.compile(
    r"^--+[\s*]*@param\s+([a-zA-Z0-9_]+)\s*(?:\((.*?)\)|(\S+))?\s*(.*)$"
)
RETURN_REGEX = re.compile(
    r"^--+[\s*]*@return\s*(?:\((.*?)\)|(\S+))?\s*(.*)$"
)


def clean_pipes(text: str) -> str:
    return (text or "").replace("|", "\\|")


def parse_lua_file(filepath: Path):
    classes = []
    functions = []

    current_class = None
    current_doc = {"desc": [], "params": [], "returns": []}
    last_target = None

    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            stripped = line.strip()

            if stripped.startswith("--"):
                # @class detection
                m_class = CLASS_REGEX.match(stripped)
                if m_class:
                    if current_class:
                        classes.append(current_class)
                    current_class = {
                        "name": m_class.group(1),
                        "desc": m_class.group(2) or "",
                        "fields": [],
                    }
                    last_target = None
                    continue

                # @field detection (only if inside a class)
                if current_class and "@field" in stripped:
                    m_field = FIELD_REGEX.match(stripped)
                    if m_field:
                        field_obj = {
                            "name": m_field.group(1),
                            "type": m_field.group(2) or "any",
                            "desc": m_field.group(3) or "",
                        }
                        current_class["fields"].append(field_obj)
                        last_target = field_obj
                    continue

                # @param detection
                if "@param" in stripped:
                    m_param = PARAM_REGEX.match(stripped)
                    if m_param:
                        p_type = m_param.group(2) or m_param.group(3) or "any"
                        param_obj = {
                            "name": m_param.group(1),
                            "type": p_type.strip(),
                            "desc": m_param.group(4).strip(),
                        }
                        current_doc["params"].append(param_obj)
                        last_target = param_obj
                    continue

                # @return detection
                if "@return" in stripped:
                    m_ret = RETURN_REGEX.match(stripped)
                    if m_ret:
                        r_type = m_ret.group(1) or m_ret.group(2) or "any"
                        ret_obj = {
                            "type": r_type.strip(),
                            "desc": m_ret.group(3).strip(),
                        }
                        current_doc["returns"].append(ret_obj)
                        last_target = ret_obj
                    continue

                # Multiline description handling (lines starting with -- but not @param/@return/@field)
                text = re.sub(r"^--+[\s*]?", "", stripped).strip()
                if text and not text.startswith("@author"):
                    if last_target and not text.startswith("@"):
                        last_target["desc"] += f" {text}"
                    else:
                        last_target = None
                        current_doc["desc"].append(text)
                continue

            # We tolerate empty line between docblock and function
            if not stripped:
                continue

            # Function signature detection
            m_func = FUNC_REGEX.match(stripped)
            if m_func:
                if (
                    current_doc["desc"]
                    or current_doc["params"]
                    or current_doc["returns"]
                ):
                    func_name = m_func.group(1) or m_func.group(3)
                    args_str = m_func.group(2) if m_func.group(1) else m_func.group(4)
                    raw_args = [
                        a.strip() for a in (args_str or "").split(",") if a.strip()
                    ]

                    functions.append(
                        {
                            "name": func_name,
                            "args": raw_args,
                            "desc": " ".join(current_doc["desc"]),
                            "params": current_doc["params"],
                            "returns": current_doc["returns"],
                        }
                    )
                current_doc = {"desc": [], "params": [], "returns": []}
                last_target = None
            else:
                # Resets the docs buffer if we encounter a non-doc, non-function line
                current_doc = {"desc": [], "params": [], "returns": []}
                last_target = None

    if current_class:
        classes.append(current_class)

    return {"classes": classes, "functions": functions}


def main():
    if not LUA_DIR.exists():
        print(f"ERROR : Directory {LUA_DIR} does not exist.")
        return

    modules = {}
    for root, _, files in os.walk(LUA_DIR):
        for file in sorted(files):
            if file.endswith(".lua"):
                path = Path(root) / file
                rel_path = path.relative_to(LUA_DIR)
                data = parse_lua_file(path)
                if data["classes"] or data["functions"]:
                    modules[str(rel_path)] = data

    output = ["# PingouinMod Documentation\n"]

    for mod_path, data in sorted(modules.items()):
        output.append(f"## Module `{mod_path}`\n")

        # Class/Enum/Types render
        if data["classes"]:
            for cls in data["classes"]:
                output.append(f"### Struct / Class `{cls['name']}`\n")
                if cls["desc"]:
                    output.append(f"{cls['desc']}\n")
                if cls["fields"]:
                    output.append("| Field | Type | Description |")
                    output.append("| :--- | :--- | :--- |")
                    for f in cls["fields"]:
                        c_name = clean_pipes(f["name"])
                        c_type = clean_pipes(f["type"])
                        c_desc = clean_pipes(f["desc"])
                        output.append(f"| `{c_name}` | `{c_type}` | {c_desc} |")
                    output.append("")
                output.append("---\n")

        # Functions render
        if data["functions"]:
            for fn in data["functions"]:
                sig = f"{fn['name']}({', '.join(fn['args'])})"
                output.append(f"### Fonction `{sig}`\n")

                if fn["desc"]:
                    output.append(f"{fn['desc']}\n")

                if fn["params"]:
                    output.append("**Parameters :**\n")
                    output.append("| Name | Type | Description |")
                    output.append("| :--- | :--- | :--- |")
                    for p in fn["params"]:
                        p_name = clean_pipes(p["name"])
                        p_type = clean_pipes(p["type"])
                        p_desc = clean_pipes(p["desc"])
                        output.append(f"| `{p_name}` | `{p_type}` | {p_desc} |")
                    output.append("")

                if fn["returns"]:
                    output.append("**Returns :**\n")
                    for r in fn["returns"]:
                        r_type = clean_pipes(r["type"])
                        r_desc = clean_pipes(r["desc"])
                        output.append(f"- `{r_type}` : {r_desc}")
                    output.append("")

                output.append("---\n")

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(output))

    print(f"Docs generated successfully in {OUTPUT_FILE}")


if __name__ == "__main__":
    main()