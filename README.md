# Stiffness method

Solves for nodal displacements in a frame construction.


Given a construction consisting of
  - A set of nodes in [x, y] coordinates
  - Elements with with specified properties (Young's modulus, area, area moment of inertia) connecting the nodes
  - Nodal constraints
  - Nodal forces and moments

returns a vector with nodal displacements, including both translation in [x, y] and rotation.


Below is shown an example frame. The frame consists of five nodes, A, B, C, D and E, with corresponding nodal indexes 1 through 5. All elements have length L except element AB with length L/2. All elements have the angle 60 degrees with each other. All elements are of the same material with parameters: E = 210GPA, L = 5m, b = 0.080m, h = 0.150m, PCy = -500kN.


![Image](figures/system_drawing.PNG?raw=true)



Displacements in [x, y] for points B, C and E:
  - Bx = 0.86mm, By = -1.81mm
  - Cx = 1.43mm, Cy = -7.09mm
  - Ex = -1.15mm, Ey = -4.28mm

![Image](figures/solution_plot.jpg?raw=true)
Note the solution has been scaled by a factor of 50 to make the displacements visible.
