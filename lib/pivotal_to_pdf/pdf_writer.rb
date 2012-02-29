#!/usr/bin/env ruby

require 'rubygems'
require 'prawn'
require 'rainbow'

module PivotalToPdf
  class PdfWriter
    attr_reader :stories
    private :stories
    def initialize(stories)
      @stories = stories
      p stories.size
    end

    def write_to(destination)
      Prawn::Document.generate("#{destination}.pdf",
                               :page_layout => :landscape,
                               :margin      => [10, 10, 10, 10],
                               :page_size   => [302, 432]) do |pdf|

        pdf.font_families.update("DejaVu Sans" => {
          :normal => "#{Dir.pwd}/assets/fonts/DejaVuSans.ttf",
          :italic => "#{Dir.pwd}/assets/fonts/DejaVuSans-Oblique.ttf",
          :bold   => "#{Dir.pwd}/assets/fonts/DejaVuSans-Bold.ttf",
        })
        pdf.font "DejaVu Sans"
        # pdf.start_new_page

        stories.each_with_index do |story, index|
          padding = 10
          pdf.stroke_color = story.story_color
          pdf.stroke_bounds
          width = 370
          pdf.line_width=6
          # --- Write content
          pdf.bounding_box [pdf.bounds.left+padding, pdf.bounds.top-padding], :width => width do
            pdf.text story.formatted_name, :size => 14, :inline_format => true
            pdf.fill_color "52D017"
            pdf.text story.label_text, :size => 8
            pdf.text "\n", :size => 14
            pdf.fill_color "444444"
            pdf.text story.formatted_description || "", :size => 10, :inline_format => true
            pdf.fill_color "000000"
          end
          pdf.line(pdf.bounds.bottom_left, pdf.bounds.bottom_right)
          pdf.stroke_bounds

          pdf.text_box story.points, :size => 12, :at => [12, 50], :width => width-18 unless story.points.nil?
          pdf.text_box "Owner: " + (story.respond_to?(:owned_by) ? story.owned_by : "None"),
            :size => 8, :at => [12, 18], :width => width-18

          pdf.fill_color "999999"
          pdf.text_box story.story_type.capitalize, :size => 8,  :align => :right, :at => [12, 18], :width => width-18
          pdf.fill_color "000000"
          pdf.start_new_page unless index == stories.size - 1
        end
        # pdf.number_pages "<page>/<total>", {:at => [pdf.bounds.right - 16, -28]}

        puts ">>> Generated PDF file in '#{destination}.pdf'".foreground(:green)
                               end
    rescue Exception
      puts "[!] There was an error while generating the PDF file... What happened was:".foreground(:red)
      raise
    end
  end
end
