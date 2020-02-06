// Visit The Stimulus Handbook for more details
// https://stimulusjs.org/handbook/introduction
//
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "stimulus"

export default class extends Controller {
  //static targets = [ "output" ]

  connect() {
    this.element.innerHTML = "Loading..."

    fetch(this.data.get("url"))
      .then(response => response.text())
      .then(html => {
        this.element.innerHTML = html
      })

    //this.outputTarget.textContent = 'Hello, Stimulus! XXX'
  }
}
