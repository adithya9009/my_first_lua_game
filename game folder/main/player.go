components {
  id: "player"
  component: "/main/player.script"
}
embedded_components {
  id: "body"
  type: "sprite"
  data: "default_animation: \"front\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 32.0\n"
  "  y: 28.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/body.tilesource\"\n"
  "}\n"
  ""
  position {
    x: 477.0
    y: 314.0
  }
  scale {
    x: 10.0
    y: 10.0
    z: 10.0
  }
}
embedded_components {
  id: "head"
  type: "sprite"
  data: "default_animation: \"front\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/head.tilesource\"\n"
  "}\n"
  ""
  position {
    x: 477.0
    y: 314.0
  }
  scale {
    x: 10.0
    y: 10.0
    z: 10.0
  }
}
