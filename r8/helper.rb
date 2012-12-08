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
    #  :scope => [:views, :xxx, :xxx]
    #  :default => ''
    def vt key, options = {}
      prefix = self.view_renderer.lookup_context.prefixes[0]
      options[:scope] = [:views].concat(prefix.split('.').map{|x| x.to_sym })
      options[:default] = '' unless options.key?(:default)
      return I18n.t key, options
    end

    # I18n breadcrumb list
    def bc_link_to path, options = {}
      label = options[:label]||I18n.t("path.#{path}")
      return link_to label, path
    end
    # View
    # = bcl [ :root, :seach, { path: search_path(k: @keyword), label: vt("search.path", k: @keyword) } ], s: "/"
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
      return bcl.join(sepalator).html_safe
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
    #       _default:
    #         title: "個別設定が見つからない場合のタイトル"
    #         description: "個別設定が見つからない場合のディスクリプション"
    #         keywords: "個別設定が見つからない場合のキーワード"
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
    [:title, :description, :keywords, :h1, :footer].each do |name|
      define_method "seo_#{name}" do
        I18n.t(name, build_i18n_options(:seo, name, @i18n_opts))
      end
    end
    
    ###########################################################
    # ogp i18n helper
    ###########################################################

    # HOW TO
    #
    #   $ vim locales/ja/ogp.yml
    #   
    #     - title       : og:title
    #     - description : og:description
    #     - url         : og:url
    #     - image       : og:image
    #
    #     ja:
    #       ogp:
    #
    #         # DEFAULT
    #         title: 
    #         description:
    #         url:
    #         image:
    #
    #         # PAGES
    #         %controller_name%:
    #           %action_name%:
    #             title: "AAAAAAAAAAAAAAAAAAAA"
    #             description: "AAAAAAAAAAAAAAAAAAA"
    #             url: "http://***********"
    #             image: "http://*********.jpg"
    #
    #   $ vim app/views/parts/_ogp.html.slim
    #
    #     meta content=ogp_title property="og:title"
    #     meta content="album" property="og:type"
    #     meta content=ogp_description property="og:description"
    #     meta content=ogp_url property="og:url"
    #     meta content=ogp_image property="og:image"
    #     meta content="sokuTile" property="og:site_name"
    #
    def ogp_title
      I18n.t("ogp.#{params[:controller]}.#{params[:action]}.title",(@i18n_opts||{}).merge({ default: I18n.t("ogp.title") }) )
    end

    def ogp_description
      I18n.t("ogp.#{params[:controller]}.#{params[:action]}.description",(@i18n_opts||{}).merge({ default: I18n.t("ogp.description") }) )
    end

    def ogp_url
      I18n.t("ogp.#{params[:controller]}.#{params[:action]}.url",(@i18n_opts||{}).merge({ default: I18n.t("ogp.url") }) )
    end

    def ogp_image
      I18n.t("ogp.#{params[:controller]}.#{params[:action]}.image",(@i18n_opts||{}).merge({default: I18n.t("ogp.image")}) )
    end

    private
    # Construct options of the I18n.translate
    def build_i18n_options type, key, options = {}
      options ||= {}
      options[:scope] = [type, params[:controller].to_sym, params[:action].to_sym]
      options[:default] = I18n.t("seo.#{key}", default: '') 
      return options
    end

  end
end
