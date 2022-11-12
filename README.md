# Stiffness method

Solves for nodal displacements in a frame construction.


Given a construction consisting of
  - A set of nodes in [x, y] coordinates
  - Elements with with specified properties (Young's modulus, area, area moment of inertia) connecting the nodes
  - Nodal constraints
  - Nodal forces and moments

returns a vector with nodal displacements, including both translation in [x, y] and rotation.


Below is shown an example frame with parameters: E = 210GPA, L = 5m, b = 0.080m, h = 0.150m, PCy = -500kN.

Displacements in [x, y] for points B, C and E:
  - asdf





![Image](solution.JPG?raw=true)
