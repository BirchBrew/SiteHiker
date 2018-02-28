(function IIFE() {
  // Selectors
  const input = document.querySelector("#input")
  const siteList = document.querySelector("#site-list")
  const submit = document.querySelector("#submit")

  const sites = []
  const known_sites = []

  resetInput()

  // Logic
  function resetInput() {
    input.select()
    submit.removeAttribute("disabled")
    submit.textContent = "GO"
  }

  function makeXImage() {
    const x = new Image(10, 10)
    x.src = "images/x.png"
    return x
  }

  function createSitelist() {
    siteList.innerHTML = ''
    unknown_sites = sites.filter(site => known_sites.includes(site) === false)
    for (const site of unknown_sites) {
      const item = document.createElement("li")
      const anchor = document.createElement("a")
      anchor.setAttribute("href", `http://${site}`)
      anchor.setAttribute("target", "_blank")
      anchor.setAttribute("rel", "noopener noreferrer")
      const text = document.createTextNode(site)
      anchor.appendChild(text)
      item.appendChild(anchor)
      const x = makeXImage();
      item.appendChild(x)
      siteList.appendChild(item)

      x.onclick = function () {
        item.remove()
        const siteName = text.textContent
        known_sites.push(siteName)
        input.value = siteName
        fetchSites(siteName)
      }
    }
  }

  function fetchSites(site) {
    if (site === '') {
      return
    }
    submit.setAttribute("disabled", true)
    submit.textContent = "Thinking..."
    fetch(`/lookup?site=${encodeURIComponent(site)}`).then(response => {
      return response.json()
    }).then(data => {
      const {
        relatedSites
      } = data
      for (const site of relatedSites) {
        if (!sites.includes(site)) {
          sites.push(site)
        }
        sites.sort()
        createSitelist()
      }
    }).catch((err => {
      console.error(err)
    })).then(() => {
      resetInput()
    })
  }

  function fetchSitesTextbox() {
    fetchSites(input.value.trim())
  }

  input.addEventListener("keydown", e => {
    if (e.keyCode === 13) {
      fetchSitesTextbox()
    }
  })
  submit.addEventListener("click", fetchSitesTextbox)
})()
