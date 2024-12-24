import re

def parse_circuit_file(filename):
    # Read the file
    with open(filename, 'r') as f:
        lines = f.readlines()

    # Separate input definitions and gate definitions
    input_defs = []
    gate_defs = []

    for line in lines:
        line = line
        if not line:
            continue
        if line.startswith(('x', 'y')):
            input_defs.append(line)
        elif ' -> ' in line:
            gate_defs.append(line)

    # Generate DOT file content
    dot_content = [
        'strict digraph LogicCircuit {',
        '    layout=dot;',
        '    rankdir=LR;',
        '    node [shape=box, fontsize=10];',
        '    edge [fontsize=8];',
        '',
        '    // Input nodes',
        '    subgraph cluster_inputs {',
        '        label="Inputs";',
        '        node [style=filled, fillcolor=lightblue];'
    ]

    # Add input nodes
    x_inputs = sorted([d.split(':')[0] for d in input_defs if d.startswith('x')])
    y_inputs = sorted([d.split(':')[0] for d in input_defs if d.startswith('y')])

    dot_content.append('        {rank=same; ' + ' '.join(x_inputs) + '}')
    dot_content.append('        {rank=same; ' + ' '.join(y_inputs) + '}')
    dot_content.append('    }')

    # Add gate definitions
    dot_content.append('')
    dot_content.append('    // Gates and connections')

    # Track all z outputs for final subgraph
    z_outputs = set()

    for gate in gate_defs:
        inputs, output = gate.split(' -> ')
        if output.startswith('z'):
            z_outputs.add(output)

        # Parse gate type and inputs
        if ' AND ' in inputs:
            in1, in2 = inputs.split(' AND ')
            # Create separate edges for each input
            dot_content.append(f'    {in1} -> {output} [label="AND"];')
            dot_content.append(f'    {in2} -> {output} [label="AND"];')
        elif ' OR ' in inputs:
            in1, in2 = inputs.split(' OR ')
            dot_content.append(f'    {in1} -> {output} [label="OR"];')
            dot_content.append(f'    {in2} -> {output} [label="OR"];')
        elif ' XOR ' in inputs:
            in1, in2 = inputs.split(' XOR ')
            dot_content.append(f'    {in1} -> {output} [label="XOR"];')
            dot_content.append(f'    {in2} -> {output} [label="XOR"];')

    # Add output nodes subgraph
    dot_content.extend([
        '',
        '    // Output nodes',
        '    subgraph cluster_outputs {',
        '        label="Outputs";',
        '        node [style=filled, fillcolor=lightgreen];',
        f'        {{rank=same; {" ".join(sorted(z_outputs))}}};',
        '    }',
        '}'
    ])

    return '\n'.join(dot_content)

def main():
    # Generate the DOT file
    dot_content = parse_circuit_file('priv/input24.txt')

    # Write to file
    with open('circuit.dot', 'w') as f:
        f.write(dot_content)

    print("Generated circuit.dot file")
    print("To create the visualization, run:")
    print("dot -Tpng circuit.dot -o circuit.png")
    print("or")
    print("dot -Tsvg circuit.dot -o circuit.svg")

if __name__ == "__main__":
    main()