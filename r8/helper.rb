# coding: UTF-8
#
# How To
#
# 1. Setting
# $ vim app/controllers/application_controller.rb
# class ApplicationController
#   include R8::Helper
#
module R8
  module Helper

    
    def active_link_to(body, url, html_options = {}, active_options = { :class => :on })
      # Default Definitions
      request_path = url.split("?")
      path = request_path[0] if request_path.length > 0
      hash = {}
      if request_path.length > 1
        request_path[1].split("&").each do |l|
          p = l.split("=")
          hash[p[0]] = p[1]
        end
      end
      if request.path_info == path
        # Link URL's parameters matched with current page's parameters
        hash.each do |name, value|
          active_options.clear unless value == params[name]
        end
        # Set to Active 
        active_options.each do |key, value|
          if html_options.key?(key)
            html_options[key].concat(" " + value.to_s)
          else
            html_options[key] = value
          end
        end
      end
      link_to body, url, html_options
    end


    # I18n views
    def vt key, options = {}
      prefix = self.view_renderer.lookup_context.prefixes[0]
      return I18n.t(["views", prefix.gsub("/", "."), key].join("."), options)
    end

    # I18n breadcrumb list
    def bc_link_to path, options = {}
      label = options[:label]||I18n.t("path.#{path}")
      return link_to label, path
    end
    # View
    # =raw bcl [ :root, :seach, { path: search_path(k: @keyword), label: vt("search.path", k: @keyword) } ], s: "/"
    # @params list
    # @params options
    def bcl list, options = {}
      bcl = []
      list.each do |e| 
        if e.is_a?(Hash)
          path  = e[:path]
          label = e[:label]||I18n.t("path.#{path}", default: path)
          bcl.push(link_to label, path)
        else
          bcl.push(bc_link_to e)
        end 
      end 
      sepalator = options[:sepalator]||options[:s]||"&gt;"
      return bcl.join(sepalator)
    end 

  end
end
