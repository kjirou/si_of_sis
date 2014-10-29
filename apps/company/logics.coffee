{Company} = require 'apps/company/models'
{Field, Form} = require 'modules/validator'


class CompanyForm extends Form
  constructor: ->
    super
    @field 'name', ((new Field)
      .type 'isRequired'
      .type 'isLength', [1, 24]
    )


logics = {}

logics.postCompany = (company, values, callback) ->
  (new CompanyForm values).validate (e, validationResult) ->
    return if e
      callback e
    else unless validationResult.isValid
      callback null, validationResult
    company.name = values.name
    company.save callback


module.exports = logics
