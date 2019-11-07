class ImagesController < ApplicationController
    def index
        image_map = Port.joins(:image_attachment).map{|p| [p.image, p.url_ip]}
        image_map.concat(Port.joins(:image_attachment).map{|p| [p.image, p.url_host]})
        @images = image_map.sort{|i| i[0].created_at}
    end

    def nuke
        image_map = Port.joins(:image_attachment).map{|p| p.image}
        image_map.concat(Port.joins(:image_attachment).map{|p| p.image})
        image_map.sort{|i| i.created_at}.each{|i| i.purge}
    end

    def scan_all
        args = {'overwrite' => false}
        ScreenshotOperatorWorker.perform_async(args)
        respond_with_notify("Re-Scan started. Please refresh this page to get new results!", "notice", "true")
    end

    def scan_all_overwrite
        args = {'overwrite' => true}
        ScreenshotOperatorWorker.perform_async(args)
        respond_with_notify("Re-Scan with overwrite started. Please refresh this page to get new results!", "notice", "true")
    end

    def respond_with_notify(message = 'Please make a selection', type = 'alert', close = "true")
        respond_to do |format|
          format.html { redirect_to images_path }
          format.js { render 'pages/notify', locals: { message: message, type: type, close: close } }
        end
    end
end
