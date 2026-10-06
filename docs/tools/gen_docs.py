import os
import re
import shutil
from pathlib import Path

# Source directory containing Lua scripts and destination docs directory
LUA_DIR = Path("scripts/code")
DOCS_DIR = Path("docs")

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
    """Escapes Markdown pipes inside table cells."""
    return (text or "").replace("|", "\\|").strip()


def parse_lua_file(filepath: Path):
    """Parses a Lua file and extracts documented classes and functions."""
    classes = []
    functions = []
    current_class = None
    current_doc = {"desc": [], "params": [], "returns": []}
    last_target = None

    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            stripped = line.strip()

            if stripped.startswith("--"):
                # Suppress TODO comments from public documentation
                if "TODO" in stripped:
                    continue

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

                # @field detection (only if inside a class definition)
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

                # Multiline description handling
                text = re.sub(r"^--+[\s*]?", "", stripped).strip()
                if text and not text.startswith("@author"):
                    if last_target and not text.startswith("@"):
                        last_target["desc"] += f" {text}"
                    else:
                        last_target = None
                        current_doc["desc"].append(text)
                continue

            # Tolerate empty lines between docblocks and definitions
            if not stripped:
                continue

            # Function declaration detection
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
                # Reset doc buffer when non-doc, non-function line is encountered
                current_doc = {"desc": [], "params": [], "returns": []}
                last_target = None

    if current_class:
        classes.append(current_class)

    return {"classes": classes, "functions": functions}


def generate_module_page(rel_path: str, data: dict) -> str:
    """Generates the Markdown content for a single module page."""
    mod_name = Path(rel_path).stem
    lines = [f"# `{mod_name}`\n", f"> Module file: `{rel_path}`\n\n---\n"]

    # Render Classes and Structs
    if data["classes"]:
        lines.append("## Structures & Classes\n")
        for cls in data["classes"]:
            lines.append(f"### `{cls['name']}`\n")
            if cls["desc"]:
                lines.append(f"{cls['desc']}\n")
            if cls["fields"]:
                lines.append("| Field | Type | Description |")
                lines.append("| :--- | :--- | :--- |")
                for f in cls["fields"]:
                    lines.append(
                        f"| `{clean_pipes(f['name'])}` | `{clean_pipes(f['type'])}` | {clean_pipes(f['desc'])} |"
                    )
                lines.append("")
            lines.append("---\n")

    # Render Functions
    if data["functions"]:
        lines.append("## Functions\n")
        for fn in data["functions"]:
            sig = f"{fn['name']}({', '.join(fn['args'])})"
            lines.append(f"### `{sig}`\n")

            if fn["desc"]:
                lines.append(f"{fn['desc']}\n")

            if fn["params"]:
                lines.append("**Parameters:**\n")
                lines.append("| Name | Type | Description |")
                lines.append("| :--- | :--- | :--- |")
                for p in fn["params"]:
                    lines.append(
                        f"| `{clean_pipes(p['name'])}` | `{clean_pipes(p['type'])}` | {clean_pipes(p['desc'])} |"
                    )
                lines.append("")

            if fn["returns"]:
                lines.append("**Returns:**\n")
                for r in fn["returns"]:
                    r_type = clean_pipes(r["type"])
                    r_desc = clean_pipes(r["desc"])
                    lines.append(f"- `{r_type}`" + (f" : {r_desc}" if r_desc else ""))
                lines.append("")

            lines.append("---\n")

    return "\n".join(lines)


def main():
    if not LUA_DIR.exists():
        print(f"Error: {LUA_DIR} does not exist.")
        return

    # Clean existing docs directory to avoid stale files
    PROTECTED_DIRS = {"assets", "stylesheets", "tools"}

    if DOCS_DIR.exists():
        for item in DOCS_DIR.iterdir():
            if item.is_file() and item.suffix == ".md":
                item.unlink()  # Supprime les anciens .md
            elif item.is_dir() and item.name not in PROTECTED_DIRS:
                shutil.rmtree(item)  # Supprime les anciens sous-dossiers générés (ex: NativeUI, utils)
    else:
        DOCS_DIR.mkdir(parents=True, exist_ok=True)

    modules = {}
    for root, _, files in os.walk(LUA_DIR):
        for file in sorted(files):
            if file.endswith(".lua"):
                path = Path(root) / file
                rel_path = path.relative_to(LUA_DIR).as_posix()
                data = parse_lua_file(path)
                if data["classes"] or data["functions"]:
                    modules[rel_path] = data

    # 1. Generate individual page for each module
    for rel_path, data in modules.items():
        doc_rel_path = Path(rel_path).with_suffix(".md")
        target_file = DOCS_DIR / doc_rel_path
        target_file.parent.mkdir(parents=True, exist_ok=True)

        content = generate_module_page(rel_path, data)
        with open(target_file, "w", encoding="utf-8") as f:
            f.write(content)

    # 2. Generate the index / landing page
    index_lines = [
        "# PingouinMod API Reference\n",
        "Welcome to the official documentation for the **PingouinMod** scripting framework.\n",
        "Select a module in the left sidebar or browse through the categories below:\n",
    ]

    categories = {}
    for mod_path in sorted(modules.keys()):
        parts = mod_path.split("/")
        cat = parts[0] if len(parts) > 1 else "Core Features"
        categories.setdefault(cat, []).append(mod_path)

    for cat, mods in categories.items():
        index_lines.append(f"### {cat}\n")
        for m in mods:
            target_link = Path(m).with_suffix("").as_posix()
            index_lines.append(f"- [{m}]({target_link}/)")
        index_lines.append("")

    with open(DOCS_DIR / "index.md", "w", encoding="utf-8") as f:
        f.write("\n".join(index_lines))

    print(f"Documentation successfully generated in {DOCS_DIR}/")


if __name__ == "__main__":
    main()