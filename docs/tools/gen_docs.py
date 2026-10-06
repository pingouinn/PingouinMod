import os
import re
import shutil
from pathlib import Path

# Source directory containing Lua scripts and destination docs directory
LUA_DIR = Path("scripts/code")
DOCS_DIR = Path("docs")

# Parsing REGEX patterns for Lua documentation comments
FUNC_REGEX = re.compile(
    r"^(local\s+)?function\s+([a-zA-Z0-9_.:]+)\s*\((.*?)\)|"
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
SEE_REGEX = re.compile(
    r"^--+[\s*]*@see\s+(\S+)(?:\s+(.*))?$"
)

# Known targets mapping for automatic cross-linking in @see
SEE_TARGET_LINKS = {
    "NativeUIVisibilityConstants": "../Constants/#constantsnativeuivisibility",
    "Constants.NativeUI.Visibility": "../Constants/#constantsnativeuivisibility",
    "ESlateVisibility": "https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/UMG/Blueprint/ESlateVisibility",
}


def clean_table_pipes(text: str) -> str:
    """
    Escapes pipes only inside table cells and outside of code spans.
    Prevents backslashes from showing up inside `foo|bar` inline code.
    """
    if not text:
        return ""
    parts = text.split("`")
    for i in range(0, len(parts), 2):
        parts[i] = parts[i].replace("|", "\\|")
    return "`".join(parts).strip()


def resolve_see_link(target: str, desc: str = "") -> str:
    """Formats an @see target into a clickable link if known, or inline code otherwise."""
    url = SEE_TARGET_LINKS.get(target)
    label = f"`{target}`"
    if url:
        link_md = f"[{label}]({url})"
    else:
        link_md = label

    return link_md + (f" ({desc})" if desc else "")


def parse_lua_file(filepath: Path):
    """Parses a Lua file and extracts documented classes and functions."""
    classes = []
    functions = []
    current_class = None
    current_doc = {"desc": [], "params": [], "returns": [], "sees": []}
    last_target = None

    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            stripped = line.strip()

            if stripped.startswith("--"):
                if "TODO" in stripped:
                    continue

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

                if "@see" in stripped:
                    m_see = SEE_REGEX.match(stripped)
                    if m_see:
                        target = m_see.group(1).strip()
                        desc = (m_see.group(2) or "").strip()
                        current_doc["sees"].append(resolve_see_link(target, desc))
                        last_target = None
                        continue

                text = re.sub(r"^--+[\s*]?", "", stripped).strip()
                if text and not text.startswith("@author"):
                    if "@see" in text:
                        parts = re.split(r"@see\s+", text, maxsplit=1)
                        if parts[0].strip():
                            if last_target and not parts[0].startswith("@"):
                                last_target["desc"] += f" {parts[0].strip()}"
                            else:
                                current_doc["desc"].append(parts[0].strip())
                        if len(parts) > 1 and parts[1].strip():
                            see_tokens = parts[1].strip().split(maxsplit=1)
                            target = see_tokens[0]
                            desc = see_tokens[1] if len(see_tokens) > 1 else ""
                            current_doc["sees"].append(resolve_see_link(target, desc))
                        last_target = None
                        continue

                    if last_target and not text.startswith("@"):
                        last_target["desc"] += f" {text}"
                    else:
                        last_target = None
                        current_doc["desc"].append(text)
                continue

            if not stripped:
                continue

            m_func = FUNC_REGEX.match(stripped)
            if m_func:
                if (
                    current_doc["desc"]
                    or current_doc["params"]
                    or current_doc["returns"]
                    or current_doc["sees"]
                ):
                    is_local = bool(m_func.group(1))
                    func_name = m_func.group(2) or m_func.group(4)
                    args_str = m_func.group(3) if m_func.group(2) else m_func.group(5)
                    raw_args = [
                        a.strip() for a in (args_str or "").split(",") if a.strip()
                    ]

                    functions.append(
                        {
                            "name": func_name,
                            "args": raw_args,
                            "is_local": is_local,
                            "desc": " ".join(current_doc["desc"]),
                            "params": current_doc["params"],
                            "returns": current_doc["returns"],
                            "sees": current_doc["sees"],
                        }
                    )
                current_doc = {"desc": [], "params": [], "returns": [], "sees": []}
                last_target = None
            else:
                current_doc = {"desc": [], "params": [], "returns": [], "sees": []}
                last_target = None

    if current_class:
        classes.append(current_class)

    return {"classes": classes, "functions": functions}


def render_function_block(fn: dict) -> list[str]:
    """Formats a single function documentation section."""
    lines = []
    # Short name for H3 so the right sidebar remains clean and readable
    raw_name = fn["name"]
    short_name = raw_name.split(":")[-1].split(".")[-1]
    
    badge = " *(internal)*" if fn.get("is_local") else ""
    lines.append(f"### {short_name}{badge}\n")

    # Full signature displayed as a code block immediately under the heading
    sig = f"{fn['name']}({', '.join(fn['args'])})"
    lines.append(f"```lua\n{sig}\n```\n")

    if fn.get("is_local"):
        lines.append("> ⚠️ **Internal function:** Not exported in the module's public API table.\n")

    if fn["desc"]:
        lines.append(f"{fn['desc']}\n")

    if fn.get("sees"):
        lines.append("**See also:** " + ", ".join(fn["sees"]) + "\n")

    if fn["params"]:
        lines.append("**Parameters:**\n")
        lines.append("| Name | Type | Description |")
        lines.append("| :--- | :--- | :--- |")
        for p in fn["params"]:
            lines.append(
                f"| `{p['name']}` | `{p['type']}` | {clean_table_pipes(p['desc'])} |"
            )
        lines.append("")

    if fn["returns"]:
        lines.append("**Returns:**\n")
        for r in fn["returns"]:
            r_type = r["type"].strip()
            r_desc = r["desc"].strip()
            lines.append(f"- `{r_type}`" + (f" : {r_desc}" if r_desc else ""))
        lines.append("")

    lines.append("---\n")
    return lines


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
                        f"| `{f['name']}` | `{f['type']}` | {clean_table_pipes(f['desc'])} |"
                    )
                lines.append("")
            lines.append("---\n")

    # Split functions into public and internal groups
    public_funcs = [f for f in data["functions"] if not f.get("is_local")]
    internal_funcs = [f for f in data["functions"] if f.get("is_local")]

    if public_funcs:
        lines.append("## Functions\n")
        for fn in public_funcs:
            lines.extend(render_function_block(fn))

    if internal_funcs:
        lines.append("## Internal Functions\n")
        for fn in internal_funcs:
            lines.extend(render_function_block(fn))

    return "\n".join(lines)


def main():
    if not LUA_DIR.exists():
        print(f"Error: {LUA_DIR} does not exist.")
        return

    PROTECTED_DIRS = {"assets", "stylesheets", "tools"}

    if DOCS_DIR.exists():
        for item in DOCS_DIR.iterdir():
            if item.is_file() and item.suffix == ".md":
                item.unlink()
            elif item.is_dir() and item.name not in PROTECTED_DIRS:
                shutil.rmtree(item)
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

    for rel_path, data in modules.items():
        doc_rel_path = Path(rel_path).with_suffix(".md")
        target_file = DOCS_DIR / doc_rel_path
        target_file.parent.mkdir(parents=True, exist_ok=True)

        content = generate_module_page(rel_path, data)
        with open(target_file, "w", encoding="utf-8") as f:
            f.write(content)

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