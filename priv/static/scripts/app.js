(function IIFE() {
  // Selectors
  const input = document.querySelector("#input")
  const siteList = document.querySelector("#site-list")
  const submit = document.querySelector("#submit")

  const sites = []

  resetInput()

  // Logic
  function resetInput() {
    input.select()
    submit.removeAttribute("disabled")
    submit.textContent = "GO"
  }

  function createSitelist() {
    siteList.innerHTML = ''
    for (const site of sites) {
      const item = document.createElement("li")
      const text = document.createTextNode(site)
      item.appendChild(text)
      siteList.appendChild(item)
    }
  }

  function fetchSites() {
    const site = input.value.trim()
    if (site === '') {
      return
    }
    submit.setAttribute("disabled", true)
    submit.textContent = "Thinking..."
    fetch(site).then(response => {
      return response.json()
    }).then(data => {
      const { relatedSites } = data
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

  input.addEventListener("keydown", e => {
    if (e.keyCode === 13) {
      fetchSites()
    }
  })
  submit.addEventListener("click", fetchSites)
})()
