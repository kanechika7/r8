# coding: UTF-8
#
#
# SETTING
#
#   $ vim app/helpers/application_helper.rb
#
#   class ApplicationHelper
#     include R8::Helper
#
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

    ###########################################################
    # seo i18n helper
    ###########################################################

    #
    # USE
    #   $ vim locales/ja/seo.yml
    #
    #   ja:
    #     seo:
    #       %controller_name:
    #         %action_name:
    #           title:
    #           description:
    #           keywords:
    #           h1:
    # 
    #
    #   $ vim app/views/layouts/application.html.haml
    #
    #   %title= seo_title
    #   %meta{ name: "description" ,content: seo_description }
    #   %meta{ meta: "keywords"    ,content: seo_keywords    }
    #
    #   %h1= seo_h1
    #
    #
    # EXTRA
    #   変数を使う場合
    #   $ vim app/controllers/******_controller.rb
    # 
    #   @i18n_opts = { book_name: @book.name }
    #
    #
    
    def seo_title
      I18n.t("seo.#{params[:controller]}.#{params[:action]}.title",@i18n_opts)
    end

    def seo_description
      I18n.t("seo.#{params[:controller]}.#{params[:action]}.description",@i18n_opts)
    end

    def seo_keywords
      I18n.t("seo.#{params[:controller]}.#{params[:action]}.keywords",@i18n_opts)
    end

    def seo_h1
      I18n.t("seo.#{params[:controller]}.#{params[:action]}.h1",@i18n_opts)
    end


  end
end
