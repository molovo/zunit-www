###*
 * Contains methods for handling scroll events on the header
 *
 * @type {Header}
###
class Header
  ###*
   * A map of key codes
   *
   * @type {object}
  ###
  keyCodes =
    ESC: 27

  ###*
   * The documentation link in the main menu
   *
   * @type {HTMLElement}
  ###
  toggle = document.querySelector '.nav--main-mobile-nav-link'

  ###*
   * Create the Header instance
   *
   * @return {Header}
  ###
  constructor: () ->
    @header = document.querySelector '.nav'
    @registerNavListeners()
    @registerHeaderScrollingListener()
    @updateVersion()

  ###*
   * Register listeners for opening and closing the documentation navigation
  ###
  registerNavListeners: () ->
    toggle.addEventListener 'click', (evt) ->
      evt.preventDefault()

      if document.body.classList.contains 'menu--open'
        document.body.classList.remove 'menu--open'
      else
        document.body.classList.add 'menu--open'

    document.addEventListener 'keydown', (evt) ->
      key = evt.keyCode or evt.which
      open = document.body.classList.contains 'menu--open'

      if open and key is keyCodes.ESC
        document.body.classList.remove 'menu--open'

  ###*
   * Register a listener which fires on scroll events
  ###
  registerHeaderScrollingListener: () ->
    window.addEventListener 'scroll', @fixHeaderOnScroll

  ###*
   * Fix the header to the top of the screen once the
   * scroll position reaches it
   *
   * @param  {Event} evt
  ###
  fixHeaderOnScroll: (evt) ->
    y = window.pageYOffset

    if y > 100
      document.body.classList.add 'scrolled'
    else
      document.body.classList.remove 'scrolled'

  ###*
   * Get the latest version number from Github's API,
   * and update version placeholders across the site
  ###
  updateVersion: () ->
    placeholder = document.querySelector '.nav--main-install-version'
    installDocs = document.querySelector '.install--version-instructions code'

    @getLatestRelease()
      .then (version) ->
        placeholder.innerHTML = version

        installDocs.innerHTML = installDocs.innerHTML
          .replace(/__version__/g, version)

  ###*
   * Get the latest version number from Github's API
   *
   * @return {Promise}
  ###
  getLatestRelease: () ->
    new Promise (resolve, reject) ->
      # Get the updated at timestamp
      updatedAt = parseInt localStorage.getItem('version_updated_at')
      timestamp = new Date().getTime()

      # If we are within the cache time, get and parse the
      # cached version number
      if (updatedAt + 300) > timestamp
        version = localStorage.getItem 'version'
        resolve version
        return

      url = 'https://api.github.com/repos/zunit-zsh/zunit/releases/latest'
      if window.baseDomain isnt 'https://zunit.xyz'
        next = true
        url  = 'https://api.github.com/repos/zunit-zsh/zunit/releases'

      # Fetch the list from the stored JSON file
      fetch url
        # Parse the JSON response
        .then (response) ->
          response.json()

        # If on 'next' site, use first release in list
        .then (response) ->
          if next
            return response[0]

          response

        # Cache the version number
        .then (response) ->
          localStorage.setItem 'version', response.tag_name
          localStorage.setItem 'version_updated_at', timestamp
          resolve response.tag_name

        # Catch parsing errors
        .catch (err) ->
          reject err



module.exports = Header
