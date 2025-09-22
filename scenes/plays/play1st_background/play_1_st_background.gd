extends ParallaxBackground

func _process(_delta):
    # This line tells the parallax background to follow the camera's position
    scroll_offset = get_viewport().get_camera_2d().get_position()