class CommonComponentTestCase extends ClassyTestCase
  @testName: 'CommonComponent'

  testConstructDatetime: ->
    component = new CommonComponent()
    @assertEqual component.constructDatetime('2015-01-03', '14:04'), new Date('2015-01-03T22:04:00.000Z')

ClassyTestCase.addTest new CommonComponentTestCase()
