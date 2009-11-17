# Name: VideoTools
# Author: Kai Kousa
# Description: Contains the low-level-methods for videoediting. 
# Contributions: fitVideoToScreen-method and most of the method-implementations
# were taken from Fooga's original sources.

require 'vre_config'
require 'tools/video_inspector'
require 'tools/video_tools'
require 'multiplexers/xvid_multiplexer'
require 'multiplexers/mpeg2_multiplexer'
require 'multiplexers/mp4_multiplexer'
require 'rubygems'
require 'RMagick'

class EffectTools
  def initialize(video_tools)
    @settings = VREConfig.instance.settings
    @video_tools = video_tools
  end
  
  def softmove(movie, visual, effect)
    
    # create blank video for background
    bg_video = @video_tools.create_black_video(movie, visual)

    # apply avfilter
    filename = movie.project.trimmed + "/" + (File.basename(visual.file)).split(".")[0] + "_filtered."

    cmd = @settings['softmove'].dup

    cmd.sub!('<background_video>', bg_video)
    
    scale_resolution = movie.resolution.split(":").collect { |el| el * 1.03 }.join(":")

    cmd.sub!('<scale_resolution>', scale_resolution)

    p effect
    
    formula = @settings['formula_'+effect.properties["direction"]].dup

    delta = 40
    speed = 50
    formula.sub!('<delta>', delta.to_s)
    formula.sub!('<delta_pi>', (delta * 2 / Math::PI).ceil.to_s)
    formula.sub!('<speed>', speed.to_s)

    cmd.sub!('<formula>', formula)

    cmd.sub!('<target>', filename + "avi")

    visual.file = filename + "avi"
    visual.type = "video"
  end
  
end
