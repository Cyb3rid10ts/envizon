class Port < ApplicationRecord
  validates :number, presence: true
  belongs_to :client
  has_many :outputs, dependent: :destroy
  has_one_attached :image
  has_one_attached :image_hostname

  def is_screenshotable?
    case service_short
    when "http", "https"
      return true
    end
    return false
  end

  def service_short
    if self.service.include?('http')
      return "https" if self.service.include?('ssl') || self.service.include?('https')
      return "http"
    end
    return "vnc" if self.service.include?('vnc')
    return nil
  end

  def url_ip
    "#{self.service_short}://#{self.client.ip}:#{self.number}/"
  end

  def url_host
    return nil unless self.client.hostname.present?
    "#{self.service_short}://#{self.client.hostname}:#{self.number}/"
  end

  def url_to_image(url)
    wd = Selenium::WebDriver.for :remote, url: 'http://selenium:4444/wd/hub', desired_capabilities: SELENIUM_CAPS
    wd.manage.timeouts.page_load = 10
    wd.navigate.to url
    sleep 5
    wd.manage.window.resize_to(1920, 1080)
    wd.screenshot_as(:png)
  end

  def screenshot
    if is_screenshotable?
      case self.service_short
      when 'http', 'https'

        img =  url_to_image(self.url_ip)
        img_host = url_to_image(self.url_host) if self.clinet.hostname.present?
      end

      self.image.attach(io: StringIO.new(img), filename: "screenshot_#{self.client.ip}_#{self.number}.png", content_type: 'image/png') if img
      self.image_hostname.attach(io: StringIO.new(img), filename: "screenshot_#{self.client.hostname}_#{self.number}.png", content_type: 'image/png') if img_host

    end
  end

end