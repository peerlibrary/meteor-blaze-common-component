trim = (html) =>
  html = html.replace />\s+/g, '>'
  html = html.replace /\s+</g, '<'
  html.trim()

class LevelOneMixin extends CommonMixin
  mixins: ->
    [LevelTwoMixin]

  # This one should be resolved in the template.
  hasValue: ->
    42

class LevelTwoMixin extends CommonMixin
  # This one should not be resolved in the template.
  hasNoValue: ->
    43

class LevelOneComponent extends CommonComponent
  @register 'LevelOneComponent'

  mixins: ->
    [LevelOneMixin]

  topValue: ->
    41

class LevelTwoComponent extends CommonComponent
  @register 'LevelTwoComponent'

class MainComponent extends CommonComponent
  @register 'MainComponent'

  topValue: ->
    @callAncestorWith 'topValue'

  hasValue: ->
    @callAncestorWith 'hasValue'

  hasNoValue: ->
    @callAncestorWith 'hasNoValue'

class CommonComponentTestCase extends ClassyTestCase
  @testName: 'CommonComponent'

  testConstructDatetime: ->
    component = new CommonComponent()
    @assertEqual component.constructDatetime('2015-01-03', '14:04'), new Date(2015, 0, 3, 14, 4, 0)

  testClientAncestors: [
    ->
      @renderedComponent = Blaze.render Template.testLevelOneComponent, $('body').get(0)

      Tracker.afterFlush @expect()
  ,
    ->
      @assertEqual trim($('.testLevelOneComponent').html()), trim """
        <span>41</span>
        <span>42</span>
        <span></span>
      """
  ,
    ->
      Blaze.remove @renderedComponent
  ]

  testAncestors: ->
    output = CommonComponent.getComponent('LevelOneComponent').renderComponentToHTML null, null

    @assertEqual trim(output), trim """
      <span>41</span>
      <span>42</span>
      <span></span>
    """

ClassyTestCase.addTest new CommonComponentTestCase()
