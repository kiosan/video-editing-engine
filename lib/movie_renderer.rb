# Name: MovieRenderer
# Author: Kai Kousa
# Description: MovieRenderer is responsible for directing the rendering process.

require 'tools/video_tools'
require 'tools/audio_tools'
require 'tools/effect_tools'
require 'model/audio_sequence'
require 'observable'
include Observable

class MovieRenderer
  
  def initialize(video_tool = VideoTools.new, audio_tool = AudioTools.new)
    @video_tool = video_tool
    @audio_tool = audio_tool
    @effect_tool = EffectTools.new(@video_tool)
  end
  
  def render(movie)
    update_all("MovieRenderer", "Processing audio...")
    audio_file = process_audio(movie)
    update_all("MovieRenderer", "...audioprocessing finished!")
    
    update_all("MovieRenderer", "Processing visuals...")
    process_visuals(movie)
    update_all("MovieRenderer", "...videoprocessing finished!")

    update_all("MovieRenderer", "Processing effects...")
    process_effects(movie)
    update_all("MovieRenderer", "...effects finished!")

    update_all("MovieRenderer", "Combining videos...")
    video_file = @video_tool.combine_video(movie)
    update_all("MovieRenderer", "Combining videos finished...")

    update_all("MovieRenderer", "Adding subtitles...")
    video_file = @video_tool.add_subtitles(movie)
    update_all("MovieRenderer", "...adding subtitles finished")

    update_all("MovieRenderer", "Multiplexing audio and video...")
    @video_tool.multiplex(movie, video_file, audio_file)
    update_all("MovieRenderer", "...multiplexing finished")

    

    update_all("MovieRenderer", "...generating thumbnail")
    @video_tool.generate_thumbnail(movie)

    update_all("MovieRenderer", "Rendering finished!")
  end
  
  #Convert -> Trim -> Combine -> Result: Audiotrack
  def process_audio(movie)
    audios = movie.audio_sequence.sort
    audios.each{|audio|
      @audio_tool.convert_audio(audio, movie.project)
      @audio_tool.trim_audio(audio, movie.project)
    }
    audio_sequence = AudioSequence.new
    audio_sequence.audios = audios
    movie.audio_sequence = audio_sequence
    @audio_tool.mix_audio_sequence(audio_sequence, movie.project)
  end
  
  #Trim/generate -> Combine -> Result: Videotrack
  def process_visuals(movie)
    visuals = movie.visual_sequence.sort
    visuals.each {|visual|
      if(visual.type == "video")
        @video_tool.trim_video(movie, visual)
      elsif(visual.type == "image")
        @video_tool.create_video_from_image(movie, visual)
      elsif(visual.type == "blackness")
        @video_tool.create_black_video(movie, visual)
      end
    }
    sequence = VisualSequence.new
    sequence.visuals = visuals
    movie.visual_sequence = sequence
  end
  
  def process_effects(movie)
    visuals = movie.visual_sequence.sort
    visuals.each {|visual|
      if(visual.type == "video")
        visual.effects.each do |effect|
          @effect_tool.send(effect.name.to_sym, movie, visual, effect)
        end
      end
    }
  end
end
