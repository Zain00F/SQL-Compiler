

from sqlcompiler.semantic_ast import ASTComposite, ASTLeaf, ASTNode


class ASTGraphvizExporter:
    def __init__(self):
        self.lines = []
        self.node_id = 0

    def _next_id(self):
        i = self.node_id
        self.node_id += 1
        return i

    def export(self, ast_root: ASTNode, filename="ast_tree.dot"):
        self.lines.append("digraph AST {")
        self.lines.append("  rankdir=TB;")
        self.lines.append(
            "  node [fontname=\"Arial\", shape=box, style=filled, fillcolor=lightblue];"
        )

        self._visit(ast_root)

        self.lines.append("}")

        with open(filename, "w", encoding="utf-8") as f:
            f.write("\n".join(self.lines))

        print(f"[OK] AST Graphviz file created: {filename}")

    def _visit(self, node: ASTNode, parent_id=None):
        my_id = self._next_id()

        # ---------- Leaf ----------
        if isinstance(node, ASTLeaf):
            label = f"{node.__class__.__name__}\\n{node.text}"
            self.lines.append(
                f'  node{my_id} [label="{label}", shape=ellipse, fillcolor=lightyellow];'
            )

        # ---------- Composite ----------
        else:
            label = node.__class__.__name__
            self.lines.append(f'  node{my_id} [label="{label}"];')

        if parent_id is not None:
            self.lines.append(f"  node{parent_id} -> node{my_id};")

        if isinstance(node, ASTComposite):
            for child in node.children:
                self._visit(child, my_id)
