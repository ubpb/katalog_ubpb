#= require app/path_helpers
#= require ./term

((window.app ?= {}).components ?= {}).TermsFacet = Ractive.extend
  template: """
    {{#facet}}
      <div class="facet facet-terms {{name}}">
        <div class="panel panel-primary">
          <div class="panel-heading panel-cutoffcorner">
            <h3 class="panel-title">
              {{ t(i18n_key + ".facets." + name + ".label", {defaultValue: name}) }}
            </h3>
          </div>

          <div class="panel-body">
            <ul class="nav nav-pills nav-stacked">
              {{#excluded_terms}}
                <Term></Term>
              {{/excluded_terms}}
              {{#terms:index}}
                {{#if !is_collapsed || index < collapse_threshold}}
                  <Term></Term>
                {{/if}}
              {{/terms}}
            </ul>
          </div>

          {{#if can_be_collapsed && is_collapsed}}
            <div class="panel-footer">
              <a href="#" on-click="Decollapse">
                {{ t("components.TermsFacet.expand_terms_facet", {additional_terms: facet.terms.length - collapse_threshold}) }}
              </a>
            </div>
          {{/if}}

          {{#if can_be_collapsed && !is_collapsed}}
            <div class="panel-footer">
              <a href="#" on-click="Collapse">
                {{ t("components.TermsFacet.collapse_terms_facet", {terms_to_hide: facet.terms.length - collapse_threshold}) }}
              </a>
            </div>
          {{/if}}
        </div>
      </div>
    {{/facet}}
  """

  components:
    Term: app.components.TermsFacet.Term

  computed:
    can_be_collapsed: ->
      @get("facet.terms").length > @get("collapse_threshold")

    excluded_terms: ->
      selected_facet_queries = _.select(@get("search_request.facet_queries") || [], {field: @get("facet.field"), exclude: true})
      _.map(selected_facet_queries, (facet_query) -> { term: facet_query["query"] })

  data:
    collapse_threshold: 5
    is_collapsed: true # initially the facet is collapsed

  onrender: ->
    @on "Collapse", (event) ->
      event.original.preventDefault()
      @set("is_collapsed", true)

    @on "Decollapse", (event) ->
      event.original.preventDefault() 
      @set("is_collapsed", false)

  #
  # custom
  #
  searches_path: (options = {}) ->
    app.PathHelpers.path_helper_factory(@get("searches_path"))(options)
