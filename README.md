# Stiffness method

Solves for nodal displacements in a frame construction.


Given a construction consisting of
  - A set of nodes in [x, y] coordinates
  - Elements with with specified properties (Young's modulus, area, area moment of inertia) connecting the nodes
  - Nodal constraints
  - Nodal forces and moments

returns a vector with nodal displacements, including both translation in [x, y] and rotation.


Below is shown an example frame with parameters: E = 210GPA, b = 80mm, h = 150mm, L = 5000mm





![Image](solution.JPG?raw=true)
