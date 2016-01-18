#= require app/Component
#= require ./range

do(app = window.app, Range = app.components.RangeFacet.Range) ->
  (app.components ?= {}).RangeFacet = app.Component.extend
    components:
      Range: Range

    onconfig: ->
      @set("searches_path", @_path_helper_factory(@get("searches_path")))

    template: """
      {{#facet}}
        <div class="facet facet-range {{name}}">
          <div class="panel panel-primary">
            <div class="panel-heading panel-cutoffcorner">
              <h3 class="panel-title">
                {{ t(i18n_key + ".facets." + name + ".label", {defaultValue: name}) }}
              </h3>
            </div>

            <div class="panel-body">
              <ul class="nav nav-pills nav-stacked">
                {{#ranges}}
                  <Range count={{.count}} from={{.from}} key={{.key}} to={{.to}}></Range>
                {{/terms}}
              </ul>
            </div>
          </div>
        </div>
      {{/facet}}
    """
