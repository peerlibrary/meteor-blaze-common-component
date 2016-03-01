class CommonComponentTestCase extends ClassyTestCase
  @testName: 'CommonComponent'

  testConstructDatetime: ->
    component = new CommonComponent()
    @assertEqual component.constructDatetime('2015-01-03', '14:04'), new Date(2015, 0, 3, 14, 4, 0)

ClassyTestCase.addTest new CommonComponentTestCase()
