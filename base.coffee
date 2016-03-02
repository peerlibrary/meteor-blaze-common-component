expirationMsFromDuration = (duration) ->
  # Default values from  moment/src/lib/duration/humanize.js.
  thresholds =
    s: 45 # seconds to minute
    m: 45 # minutes to hour
    h: 22 # hours to day

  seconds = Math.round(duration.as 's')
  minutes = Math.round(duration.as 'm')
  hours = Math.round(duration.as 'h')

  if seconds < thresholds.s
    (thresholds.s - seconds) * 1000 + 500
  else if minutes < thresholds.m
    (60 - seconds % 60) * 1000 + 500
  else if hours < thresholds.h
    ((60 * 60) - seconds % (60 * 60)) * 1000 + 500
  else
    ((24 * 60 * 60) - seconds % (24 * 60 * 60)) * 1000 + 500

invalidateAfter = (expirationMs) ->
  computation = Tracker.currentComputation
  handle = Meteor.setTimeout =>
    computation.invalidate()
  ,
    expirationMs
  computation.onInvalidate =>
    Meteor.clearTimeout handle if handle
    handle = null

# A common base class for both {CommonComponent} and {CommonMixin}.
class CommonComponentBase extends BlazeComponent
  # A version of [subscribe](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_subscribe)
  # which logs errors to the console if no error callback is specified.
  #
  # @return [SubscriptionHandle]
  subscribe: (name, args...) ->
    lastArgument = args[args.length - 1]

    callbacks = {}
    if _.isFunction lastArgument
      callbacks.onReady = args.pop()
    else if _.any [lastArgument?.onReady, lastArgument?.onError, lastArgument?.onStop], _.isFunction
      callbacks = args.pop()

    unless callbacks.onError or callbacks.onStop
      callbacks.onStop = (error) =>
        console.error "Subscription '#{args[0]}' error", error if error

    args.push callbacks

    super name, args...

  # Traverses the components tree towards the root and returns the first component which is an instance of
  # `componentClass`.
  #
  # @param [Class<componentClass>] componentClass
  # @return [BlazeComponent]
  ancestorComponent: (componentClass) ->
    component = @parentComponent()
    while component and component not instanceof componentClass
      component = component.parentComponent()
    component

  # Traverses the components tree towards the root and finds the first component with a property `propertyName`
  # and if it is a function, calls it with `args` arguments, otherwise returns the value of the property.
  #
  # @param [String] propertyName
  # @return [anything]
  callAncestorWith: (propertyName, args...) ->
    component = @parentComponent()
    while component and not component.getFirstWith null, propertyName
      component = component.parentComponent()
    component?.callFirstWith null, propertyName, args...

# A base class for components with additional methods for various useful features.
#
# In addition to methods/template helpers available when using this class as a base
# class, [`insertDOMElement`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_insertDOMElement),
# [`moveDOMElement`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_moveDOMElement),
# and [`removeDOMElement`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_removeDOMElement) have been
# configured to call corresponding methods in mixins, if they exist, as it is
# described [in Blaze Components documentation](https://github.com/peerlibrary/meteor-blaze-components#animations).
# This allows you to use mixins which add animations to your components.
class CommonComponent extends CommonComponentBase
  # @nodoc
  insertDOMElement: (parent, node, before, next) ->
    next ?= =>
      super parent, node, before
      true

    return next() unless @callFirstWith @, 'insertDOMElement', parent, node, before, next

    # It has been handled.
    true

  # @nodoc
  moveDOMElement: (parent, node, before, next) ->
    next ?= =>
      super parent, node, before
      true

    return next() unless @callFirstWith @, 'moveDOMElement', parent, node, before, next

    # It has been handled.
    true

  # @nodoc
  removeDOMElement: (parent, node, next) ->
    next ?= =>
      super parent, node
      true

    return next() unless @callFirstWith @, 'removeDOMElement', parent, node, next

    # It has been handled.
    true

  # Template helper which resolves [Flow Router](https://github.com/kadirahq/flow-router) path definition and arguments to
  # URL paths using [`FlowRouter.path`](https://github.com/kadirahq/flow-router#flowrouterpathpathdef-params-queryparams).
  # It works when Flow Router package is available.
  #
  # @example
  #   {{pathFor 'Post.edit' params=data}}
  #
  # @param [String] pathName Path name or path definition.
  # @param [Object] kwargs
  # @option kwargs [Object] params Parameters to resolve variables in the path.
  # @option kwargs [Object] query Query string values to be added to the URL path.
  # @return [String]
  pathFor: (pathName, kwargs) ->
    kwargs = kwargs.hash if kwargs instanceof Spacebars.kw

    params = kwargs?.params or {}
    queryParams = kwargs?.query or {}

    FlowRouter = Package['peerlibrary:flow-router']?.FlowRouter or Package['kadira:flow-router']?.FlowRouter

    throw new Error "FlowRouter package missing." unless FlowRouter

    FlowRouter.path pathName, params, queryParams

  # Returns the [`Meteor.userId()`](http://docs.meteor.com/#/full/meteor_users) value.
  # Use it instead of [`currentUser`](http://docs.meteor.com/#/full/template_currentuser) template helper when you want
  # to check only if user is logged in or not.
  #
  # @example
  #   {{#if currentUserId}}
  #     Logged in.
  #   {{/if}}
  #
  # @return [String]
  currentUserId: ->
    Meteor.userId()

  # Extended version of [`currentUser`](http://docs.meteor.com/#/full/template_currentuser) template helper which
  # can optionally limit fields returned in the user object. This limits template helper's reactivity as well.
  # It works when [peerlibrary:user-extra](https://github.com/peerlibrary/meteor-user-extra) package is available
  # and falls back to old behavior if it is not.
  #
  # @param [String] userId
  # @param [Object] fields [MongoDB fields specifier](http://docs.meteor.com/#/full/fieldspecifiers).
  # @return [Object]
  currentUser: (userId, fields) ->
    if not fields and _.isObject userId
      fields = userId
      userId = null

    fields = fields.hash if fields instanceof Spacebars.kw

    Meteor.user userId, fields

  $or: (args...) ->
    # Removing kwargs.
    args.pop() if args[args.length - 1] instanceof Spacebars.kw

    _.some args

  $and: (args...) ->
    # Removing kwargs.
    args.pop() if args[args.length - 1] instanceof Spacebars.kw

    _.every args

  $not: (args...) ->
    # Removing kwargs.
    args.pop() if args[args.length - 1] instanceof Spacebars.kw

    not args[0]

  $join: (delimiter, args...) ->
    # Removing kwargs.
    args.pop() if args[args.length - 1] instanceof Spacebars.kw

    args.join delimiter

  DEFAULT_DATETIME_FORMAT:
    'llll'

  DEFAULT_DATE_FORMAT:
    'll'

  DEFAULT_TIME_FORMAT:
    'LT'

  fromNow: (date, withoutSuffix, options) ->
    if withoutSuffix instanceof Spacebars.kw
      options = withoutSuffix
      withoutSuffix = false

    momentDate = moment(date)

    if Tracker.active
      absoluteDuration = moment.duration(to: momentDate, from: moment()).abs()
      expirationMs = expirationMsFromDuration absoluteDuration
      invalidateAfter expirationMs

    momentDate.fromNow withoutSuffix

  formatDate: (date, format) ->
    format = null if format instanceof Spacebars.kw

    moment(date).format format

  # @todo Support internationalization.
  formatDuration: (from, to, size) ->
    size = null if size instanceof Spacebars.kw

    reactive = not (from and to)

    from ?= new Date()
    to ?= new Date()

    duration = moment.duration({from, to}).abs()

    minutes = Math.round(duration.as 'm') % 60
    hours = Math.round(duration.as 'h') % 24
    days = Math.round(duration.as 'd') % 7
    weeks = Math.floor(Math.round(duration.as 'd') / 7)

    partials = [
      key: 'week'
      value: weeks
    ,
      key: 'day'
      value: days
    ,
      key: 'hour'
      value: hours
    ,
      key: 'minute'
      value: minutes
    ]

    # Trim zero values from the left.
    while partials.length and partials[0].value is 0
      partials.shift()

    # Cut the length to provided size.
    partials = partials[0...size] if size

    if reactive and Tracker.active
      seconds = Math.round(duration.as 's')

      if partials.length
        lastPartial = partials[partials.length - 1].key
        if lastPartial is 'minute'
          expirationMs = (60 - seconds % 60) * 1000 + 500
        else if lastPartial is 'hour'
          expirationMs = ((60 * 60) - seconds % (60 * 60)) * 1000 + 500
        else
          expirationMs = ((24 * 60 * 60) - seconds % (24 * 60 * 60)) * 1000 + 500
      else
        assert seconds < 60, seconds
        expirationMs = (60 - seconds) * 1000 + 500

      invalidateAfter expirationMs

    partials = for {key, value} in partials
      # Maybe there are some zero values in-between, skip them.
      continue if value is 0

      key = "#{key}s" if value isnt 1

      "#{value} #{key}"

    if partials.length
      partials.join ' '
    else
      "less than a minute"

  # Construct a date object from inputs of form fields of type "date" and "time".
  constructDatetime: (date, time) ->
    # TODO: Make a warning or something?
    throw new Error "Both date and time fields are required together." if (date and not time) or (time and not date)

    return null unless date and time

    moment("#{date} #{time}", 'YYYY-MM-DD HH:mm').toDate()

  calendarDate: (date) ->
    moment(date).calendar null,
      lastDay: '[yesterday at] LT',
      sameDay: '[today at] LT',
      nextDay: '[tomorrow at] LT',
      lastWeek: '[last] dddd [at] LT',
      nextWeek: 'dddd [at] LT',
      sameElse: @DEFAULT_DATETIME_FORMAT

  # Returns the CSS prefix used by the current browser.
  #
  # @return [String]
  cssPrefix: ->
    unless '_cssPrefix' of @
      styles = window.getComputedStyle document.documentElement, ''
      @_cssPrefix = (_.toArray(styles).join('').match(/-(moz|webkit|ms)-/) or (styles.OLink is '' and ['', 'o']))[1]
    @_cssPrefix

# A base class for mixins which calls the following methods on the
# [mixin parent](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_mixinParent)
# instead of the mixin itself:
#
# * [`$`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_$)
# * [`find`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_find)
# * [`findAll`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_findAll)
# * [`firstNode`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_firstNode)
# * [`lastNode`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_lastNode)
# * [`data`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_data)
# * [`component`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_component)
# * [`parentComponent`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_parentComponent)
# * [`childComponents`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_childComponents)
# * [`childComponentsWith`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_childComponentsWith)
# * [`isCreated`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_isCreated)
# * [`isRendered`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_isRendered)
# * [`isDestroyed`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_isDestroyed)
# * [`renderComponent`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_renderComponent)
# * [`removeComponent`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_removeComponent)
# * [`renderComponentToHTML`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_renderComponentToHTML)
# * [`autorun`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_autorun)
# * {CommonComponentBase#subscribe `subscribe`}
# * [`subscriptionsReady`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_subscriptionsReady)
# * [`getMixin`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_getMixin)
# * [`getFirstWith`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_getFirstWith)
# * [`callFirstWith`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_callFirstWith)
# * [`requireMixin`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_requireMixin)
# * {CommonComponentBase#ancestorComponent `ancestorComponent`}
# * {CommonComponentBase#callAncestorWith `callAncestorWith`}
#
# The following class methods are not available for mixins and throw an error:
#
# * [`register`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_class_register)
# * [`renderComponent`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_class_renderComponent)
# * [`renderComponentToHTML`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_class_renderComponentToHTML)
#
class CommonMixin extends CommonComponentBase

for classMethod in ['register', 'renderComponent', 'renderComponentToHTML']
  CommonMixin[classMethod] = ->
    throw new Error "Not available for mixins."

for method in ['$', 'find', 'findAll', 'firstNode', 'lastNode', 'data', 'component', 'parentComponent',
               'childComponents', 'childComponentsWith', 'isCreated', 'isRendered', 'isDestroyed', 'renderComponent',
               'removeComponent', 'renderComponentToHTML', 'autorun', 'subscribe', 'subscriptionsReady', 'getMixin',
               'getFirstWith', 'callFirstWith', 'requireMixin', 'ancestorComponent', 'callAncestorWith']
  CommonMixin::[method] = (args...) ->
    @mixinParent()[method] args...
