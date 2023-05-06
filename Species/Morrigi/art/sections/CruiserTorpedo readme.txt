I managed to make the model importing into Blender 2.49b an obj model (I used Fragmotion to make the obj). The UV coordinates are exported very well, not the materials, which have the alpha channel set to 0.0 (instead of 1.0).

As it is, Blender model will be exported with no animation and with specular colors set to 1.0, 1.0, 1.0 for all the materials used.
To make the SotS model looking pretty, open the .x file and change the specular colors of the last 3 materials (those with the texture specified and which are the only used by the model itself) from 1.0, 1.0, 1.0; to 0.0, 0.0, 0.0;. They should become something like this
  Material Mat3 {
    1.0; 1.0; 1.0; 1.0;;
    3.2;
    0.0; 0.0; 0.0;;
    0.0; 0.0; 0.0;;
  TextureFilename {    "pc_mrigi03.tga";  }
  }  // End of Material
  Material Mat3 {
    1.0; 1.0; 1.0; 1.0;;
    3.2;
    0.0; 0.0; 0.0;;
    0.0; 0.0; 0.0;;
  TextureFilename {    "pc_mrigi02.tga";  }
  }  // End of Material
  Material Mat3 {
    1.0; 1.0; 1.0; 1.0;;
    3.2;
    0.0; 0.0; 0.0;;
    0.0; 0.0; 0.0;;
  TextureFilename {    "pc_mrigi01.tga";  }