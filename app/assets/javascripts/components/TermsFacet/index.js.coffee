#= require component_helpers
#= require ./term

((window.app ?= {}).components ?= {}).TermsFacet = Ractive.extend
  template: """
    {{#facet}}
      <div class="facet term-facet {{name}}">
        <div class="panel panel-primary">
          <div class="panel-heading panel-cutoffcorner">
            <h3 class="panel-title">
              {{ t("facets." + name, {defaultValue: name}) }}
            </h3>
          </div>

          <div class="panel-body">
            <ul class="nav nav-pills nav-stacked">
              {{#terms:index}}
                {{#if !is_collapsed || index < collapse_threshold}}
                  <Term>
                    <li class="term">
                      {{#if selected_by_search_request}}
                        <a href="{{remove_term_path}}">
                          <i class="fa fa-check-square-o"></i>
                          <div class="label label-info">
                            {{translated_term}}
                            {{#if count}}({{count}}){{/if}}
                          </div>
                        </a>
                      {{else}}
                        <a href="{{include_term_path}}">
                          <i class="fa fa-square-o"></i>
                          {{translated_term}}
                          {{#if count}}({{count}}){{/if}}
                        </a>
                      {{/if}}
                    </li>
                  </Term>
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

  data:
    collapse_threshold: 5
    is_collapsed: true # initially the facet is collapsed

  onrender: ->
    @on "Collapse", -> @set("is_collapsed", true)
    @on "Decollapse", -> @set("is_collapsed", false)

  #
  # custom
  #
  searches_path: (options = {}) ->
    app.ComponentHelpers.path_helper_factory(@get("searches_path"))(options)
