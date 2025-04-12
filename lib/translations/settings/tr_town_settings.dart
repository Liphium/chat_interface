import 'package:get/get.dart';

class TownSettingTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    //* English US
    'en_US': {
      // Town management
      'settings.town.info': 'Town info',
      'settings.town.own_town': 'Info about your own town',
      'settings.town.own_town.desc': 'Connected to @domain on version @version (protocol version: @protocol)',
      'settings.town.address': 'Your address',
      'settings.town.address.desc': 'This address can be used to add you as a friend by people outside of your town.',
      'settings.town.address.copied': 'Your address has been copied. Anyone can use it add you as a friend.',
      'settings.town.settings': 'Town settings',
      'settings.town.help': 'Get help with your town setup',
      'settings.town.help.desc':
          'Have any questions about your town or just want to read a little bit about the interals of Liphium? You can find all of it in our documentation for contributors & town admins. Everything like how to set up a town and even how some of Liphium works can be found there. You\'ll also find migration guides and more there as well.',

      // Admin accounts page
      'settings.accounts.count': 'Accounts created (@count)',
      'settings.accounts.none': 'No accounts found.',
      'settings.accounts.created': 'Created on @date at @time',
      'settings.accounts.delete.confirm': 'Do you really want to delete this account?',
      'settings.accounts.delete.desc':
          'This will get rid of every last thing they uploaded to your town. Please understand that conversations, messages and all chat-related content can only be deleted by the person themself because Liphium doesn\'t know which conversations you are a part of.',
      'settings.accounts.search': 'Search accounts',

      // Admin account profile
      'settings.acc_profile.title': 'Profile for @name',
      'settings.acc_profile.tab.info': 'Info',
      'settings.acc_profile.tab.actions': 'Actions',
      'settings.acc_profile.info.id': 'Account ID',
      'settings.acc_profile.info.email': 'Email address',
      'settings.acc_profile.info.username': 'Username',
      'settings.acc_profile.info.display_name': 'Display name',
      'settings.rank_change.desc':
          'Select one of the ranks below to be the new rank of the user. The permission level of the rank is in the brackets behind the name.',

      // Tabletop settings
      'settings.tabletop.decks': 'Decks',
      'settings.tabletop.decks.error':
          'An error occurred while loading your decks. This is probably something you\'ll need to report to us or it\'s just your connection. You can also try to see if there\'s a new version of the app available or try again later.',
      'settings.tabletop.decks.limit': 'Decks (@count/@limit)',
      'decks.description':
          'Decks allow you to instantly add a whole bunch of cards to a tabletop session. If you have a pack of cards you want to use often, create a deck for it!',
      'decks.create': 'Create a new deck',
      'decks.dialog.delete.title': 'Delete deck',
      'decks.dialog.delete': 'Are you sure you want to delete this deck? Think about all the cards you\'ll lose!',
      'decks.dialog.new_name': 'Type a new name for your deck here. This won\'t delete the cards in it, it\'ll just change the name.',
      'decks.dialog.name': 'First of all, please give your deck a nice name. You know, something actually good.',
      'decks.dialog.name.placeholder': 'Deck name',
      'decks.dialog.name.error': 'Please make the name for your deck longer than 3 characters.',
      'decks.limit_reached':
          'You have reached the maximum amount of decks you can create. Please delete one of your existing decks to create a new one.',
      'decks.cards': '@count cards',
      'decks.view_cards': 'View cards',
      'decks.cards.empty': 'This deck is empty. You can add cards to it by clicking the button above.',
      'settings.tabletop.general': 'General',
      'tabletop.general.framerate': 'Framerate',
      'tabletop.general.framerate.description':
          'The framerate at which the table is rendered. This should be roughly equivalent to the refresh rate of your monitor.',
      'tabletop.general.framerate.unit': 'Hz',
      'tabletop.general.color': 'The color of your cursor',
      'tabletop.general.color.description': 'This will be the color everyone sees when you are selecting something or moving your cursor.',

      // File settings
      'auto_download.images': 'Automatically download images',
      'auto_download.videos': 'Automatically download videos',
      'auto_download.audio': 'Automatically download audio',
      'settings.file.auto_download.types': 'Types of files to automatically download',
      'settings.file.max_size': 'Maximum file size for automatic downloads',
      'settings.file.max_size.description': 'Files larger than this will not be downloaded automatically.',
      'settings.file.cache': 'File cache',
      'settings.file.cache.description':
          'The file cache stores all files that have been automatically downloaded. This includes profile pictures and all other data you\'ve selected above. When it is full old files will automatically be deleted. You can select the size with the slider below or make it unlimited.',
      'settings.file.cache_type.unlimited': 'Unlimited',
      'settings.file.cache_type.size': 'Size',
      'settings.file.cache.open_cache': 'Open cache folder',
      'settings.file.cache.open_files': 'Open file folder',
      'settings.file.cache.open_saved_files': 'Open save folder',
      'settings.file.uploaded.title': 'Uploaded files (@count)',
      'settings.file.uploaded.description': 'You are currently using @current out of your available @max.',
      'settings.file.uploaded.none': 'No uploaded files. Try to send messages or create a deck to upload files.',
      'settings.file.mb': 'MB',
    },
  };
}
