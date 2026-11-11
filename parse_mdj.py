import json

def parse_mdj(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error reading file: {e}")
        return

    classes = {}
    
    def traverse(node):
        if isinstance(node, dict):
            if node.get('_type') == 'UMLClass':
                class_name = node.get('name', 'Unknown')
                attributes = []
                for attr in node.get('attributes', []):
                    attr_name = attr.get('name', '')
                    attr_type = attr.get('type', '')
                    if isinstance(attr_type, dict):
                        attr_type = attr_type.get('$ref', 'Ref')
                    attributes.append(f"{attr_name}: {attr_type}")
                classes[class_name] = attributes
            
            for key, value in node.items():
                if isinstance(value, (dict, list)):
                    traverse(value)
        elif isinstance(node, list):
            for item in node:
                traverse(item)
                
    traverse(data)
    
    for cls, attrs in classes.items():
        print(f"Class: {cls}")
        for attr in attrs:
            print(f"  - {attr}")
        print()

parse_mdj(r"c:\Users\JAVIER\Documents\Programacion\App_home\DiagramasAppHome.mdj")
