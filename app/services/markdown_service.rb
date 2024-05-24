module MarkdownService
  MARKDOWN_OPTIONS = [
    no_intra_emphasis:    true,
    tables:               true,
    fenced_code_blocks:   true,
    autolink:             true,
    strikethrough:        true,
    space_after_headers:  true,
    superscript:          true,
    underline:            true
  ].freeze

  def self.render_markdown(text, format = 'md')
    text.gsub!('](/rails/active_storage', ']('+lmo_asset_host+'/rails/active_storage')
    text.gsub!('"/rails/active_storage', '"'+lmo_asset_host+'/rails/active_storage')
    
    if format == "md"
      text
    else
      ReverseMarkdown.convert(text)
    end
  end

  def self.render_html(text)
    return '' if text.nil?
    renderer = LoomioMarkdown.new(filter_html: true, hard_wrap: true, link_attributes: {rel: "nofollow ugc noreferrer noopener", target: :_blank})
    Redcarpet::Markdown.new(renderer, *MARKDOWN_OPTIONS).render(text)
  end

  def self.render_rich_text(text, format = "md")
    return "" unless text
    text.gsub!('](/rails/active_storage', ']('+lmo_asset_host+'/rails/active_storage')
    text.gsub!('"/rails/active_storage', '"'+lmo_asset_host+'/rails/active_storage')
    if format == "md"
      MarkdownService.render_html(text)
    else
      replace_audios(replace_videos(replace_checkboxes(replace_iframes(text))))
    end.html_safe
  end

  def self.render_plain_text(text, format = 'md')
    return "" unless text
    ActionController::Base.helpers.strip_tags(render_rich_text(text, format)).gsub(/(?:\n\r?|\r\n?)/, '<br>')
  end

  def self.replace_videos(str)
    doc = Nokogiri::HTML5::DocumentFragment.parse(str)
    doc.search("video[src]").each do |node|
      node.replace("<p><a href='#{node['src']}'><img src='#{node['poster']}'><br>#{I18n.t('record_modal.watch_video')}</a></p>")
    end
    doc.to_s
  end

  def self.replace_audios(str)
    doc = Nokogiri::HTML5::DocumentFragment.parse(str)
    doc.search("audio[src]").each do |node|
      node.replace("<p><a href='#{node['src']}'>#{I18n.t('record_modal.listen_to_audio')}</a></p>")
    end
    doc.to_s
  end

  def self.replace_iframes(str)
    doc = Nokogiri::HTML5::DocumentFragment.parse(str)
    doc.search("iframe[src]").each do |node|
      begin
        vi = VideoInfo.new(node['src'])
        node.replace("<div><a href='#{vi.url}'><img src='#{vi.thumbnail}' /></a></div>")
      rescue
        node.replace("<a href='#{node['src']}'>#{node['src']}</a>")
      end
    end
    doc.to_s
  end

  def self.replace_checkboxes(str)
    frag = Nokogiri::HTML::DocumentFragment.parse(str)
    frag.css('li[data-type="taskItem"]').each do |node|
      if node['data-checked'] == 'true'
        node.prepend_child '<div class="email-checkbox">✔️</div>'
      else
        node.prepend_child '<div class="email-checkbox">&nbsp;</div>'
      end

      if node['data-due-on']
        node.add_child '<span class="mailer-tag">📅 '+node['data-due-on']+'</div>'
      end
    end
    frag.to_s
  end
end
