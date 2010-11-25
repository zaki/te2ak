#!/usr/bin/env ruby

require 'rubygems'
require 'plist'
require 'yaml'
require 'json'

## Usage:
## te2ak Settings.textexpander autokey.json
# TODO: Gemify

module TE2AK
  class Te2Ak
    POSITIONS_REGEX = /(?<!%)%\|/
    CLIPBOARD_REGEX = /(?<!%)%\(?clipboard\)?/
    SPECIALCH_REGEX = /(?<!%)%(?:[|<>]|\(?clipboard\)?)/

    def initialize
      @result = {
        'folders'=>[
          {
            'folders' => [],
            'usageCount' => 0,
            'modes' => [],
            'abbreviation' => {
              'ignoreCase' => false,
              'wordChars' => '[\\w]',
              'immediate' => false,
              'abbreviation' => nil,
              'backspace' => true,
              'triggerInside' => false
            },
            'title' => 'All',
            'hotkey' => {
              'hotKey' => nil,
              'modifiers' => []
            },
            'items' => [],
            'filter' => nil,
            'type' => 'folder',
            'showInTrayMenu' => false
          }
        ],
        'toggleServiceHotkey' => {
          'hotKey' => 'k',
          'modifiers' => ['<shift>', '<super>'],
          'enabled' => true
        },
        'settings' => {
          'showTrayIcon' => true,
          'windowDefaultSize' => [600,400],
          'undoUsingBackspace' => true,
          'enableQT4Workaround' => false,
          'promptToSave' => true,
          'interfaceType' => 'XRecord',
          'showToolbar' => true,
          'serviceRunning' => true,
          'columnWidths' => [150,50,100],
          'isFirstRun' => false,
          'sortByUsageCount' => true,
          'notificationIcon' => '/usr/share/pixmaps/akicon.png',
          'hPanePosition' => 150,
          'menuTakesFocus'=> false
        },
        'userCodeDir' => nil,
        "version" => "0.71.0", 
        "showPopupHotkey" => {
          "hotKey" => nil, 
          "modifiers" => [], 
          "enabled" => false
        }, 
        "configHotkey" => {
          "hotKey" => "k", 
          "modifiers" => ["<super>"], 
          "enabled" => true
        }
      }
    end

    def codify(str)
      # TODO: %< %> 

      jumpback = 0
      if str =~ POSITIONS_REGEX
        # assume only one place
        # calculate position based on cleared string
        str2 = str.gsub(CLIPBOARD_REGEX, '').gsub(/%%/, '')
        jumpback = str2.length - 2 - str2.rindex(POSITIONS_REGEX)
        str.gsub!(POSITIONS_REGEX, '')
      end
      str = 'keyboard.send_keys("' + str.gsub(/(?<!\\)"/, '\"').gsub(/\n/, '<enter>').gsub(CLIPBOARD_REGEX, %!");\nkeyboard.send_keys(clipboard.get_clipboard());\nkeyboard.send_keys("!) + '");'
      if jumpback != 0
        str += %!\nkeyboard.send_keys("#{'<left>'*jumpback}");!
      end
      str.gsub(/%%/, '%')
    end

    def run(input, output)
      if File.exist?(input)
        te = Plist::parse_xml File.open(input).read
        ahk = te['snippetsTE2']

        ahk.each do |a|
          script = false
          if (a['plainText'] =~ SPECIALCH_REGEX)
            code = codify(a['plainText'])
            script = true
          end
          abbreviation = {
            'usageCount' => 0,
            'omitTrigger' => false,
            'prompt' => false,
            'description' => a['label'],
            'abbreviation' => {
              'ignoreCase' => false,
              'wordChars' => "[^ \\n]",
              'immediate' => true,
              'abbreviation' => a['abbreviation'].gsub(/%%/, '%'),
              'backspace' => true,
              'triggerInside'=> false
            },
            'hotkey' => {
              'hotKey' => nil,
              'modifiers' => []
            },
            'modes' => [1],
            "showInTrayMenu" => false,
            'matchCase' => false,
            'filter' => nil,
            'sendMode' => 'kb'
          }
          if script
            abbreviation['code'] = code
            abbreviation['type'] = 'script'
            abbreviation['store'] = {}
          else
            abbreviation['phrase'] = a['plainText'].gsub(/%%/, '%')
            abbreviation['type'] = 'phrase'
          end
          @result['folders'][0]['items'] << abbreviation
        end

        File.open(output, 'w') {|f| f.write(@result.to_json) }
      end
    end
  end
end

# Process inputfile
input, output = ARGV[0], ARGV[1]
TE2AK::Te2Ak.new.run(input, output)
