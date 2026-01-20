from antlr4 import *
from antlr4.tree.Tree import TerminalNode


class ParseTreeGraphvizExporter:
    def __init__(self, parser):
        self.parser = parser
        self.lines = []
        self.node_id = 0

    def _next_id(self):
        i = self.node_id
        self.node_id += 1
        return i

    def export(self, tree, filename="parse_tree.dot"):
        self.lines.append("digraph ParseTree {")
        self.lines.append("  rankdir=TB;")
        self.lines.append("  node [fontname=\"Arial\"];")

        self._visit(tree)

        self.lines.append("}")

        with open(filename, "w", encoding="utf-8") as f:
            f.write("\n".join(self.lines))

        print(f"[OK] Graphviz file created: {filename}")

    
    def _visit(self, node, parent_id=None):
        my_id = self._next_id()

        
        if isinstance(node, TerminalNode):
            label = node.getText().replace('"', '\\"')
            self.lines.append(
                f'  node{my_id} [label="{label}", shape=ellipse];'
            )

            if parent_id is not None:
                self.lines.append(f"  node{parent_id} -> node{my_id};")

            return  

        
        rule_name = self.parser.ruleNames[node.getRuleIndex()]
        self.lines.append(
            f'  node{my_id} [label="{rule_name}", shape=box, style=filled, fillcolor=lightgray];'
        )

        if parent_id is not None:
            self.lines.append(f"  node{parent_id} -> node{my_id};")

        for child in node.getChildren():
            self._visit(child, my_id)
