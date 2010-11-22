#!/usr/bin/env ruby

require 'rubygems'
require 'plist'
require 'yaml'
require 'json'

## Usage:
## te2ak Settings.textexpander autokey.json
# TODO: Convert settings properly
# TODO: Allow control characters by converting them to scripts
# TODO: Gemify

input, output = ARGV[0], ARGV[1]

result = {
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

input,output = ARGV[0],ARGV[1]
if File.exist?(input)
  te = Plist::parse_xml File.open(input).read
  ahk = te['snippetsTE2']

  ahk.each do |a|
    result['folders'][0]['items'] << {
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
      'phrase' => a['plainText'].gsub(/%%/, '%'),
      'modes' => [1],
      "showInTrayMenu" => false,
      'matchCase' => false,
      'filter' => nil,
      'type' => 'phrase',
      'sendMode' => 'kb'
    }
  end

  File.open(output, 'w') {|f| f.write(result.to_json) }
end

