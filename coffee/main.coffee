window.Main = class Main
  constructor: () ->
    @map
    @latLngArray = []
    @latColumn = "Garage Latitude"
    @lngColumn = "Garage Longitude"
    @markLabel = "Founder"
    @flag = 0

    @userInputData = ""
    @userDetailsSection = ".UserDetails_section"

    @excludeParams = ["id", "Id", "Display on Map"]
    @popup = new Popup(@userDetailsSection, ".UserDetails_getDetails")
    @createTable = new CreateTable(@excludeParams)

    # @getUsersDataOnPageLoad() # to get data from CSV in table

    @allData =  @getCSVStoredDataArray()
    @intializeDefaultMap()

  init: ->
    $("body").on "click", "#submitInput", (e) =>
      inputText = $("#inputTextArea").val()
      unless inputText is ""
        @userInputData = $.csv.toObjects(inputText)
        @getHtmlForSelectingLatLng()
        @activeRelavantSectionInPopup $(".UserDetails_configDetails")

    $("body").on "click", "#submitConfig", (e) =>
      @latColumn = $("#configTable").find("input[type='radio'][name='latitude']:checked").attr("value")
      @lngColumn = $("#configTable").find("input[type='radio'][name='longitude']:checked").attr("value")
      @markLabel = $("#configTable").find("input[type='radio'][name='markerLabel']:checked").attr("value")

      if @latColumn isnt undefined and @lngColumn isnt undefined and @markLabel isnt undefined
        @addPropInObjects()
        html = @createTable.generateTable(@userInputData)
        $(".DataTable").addClass("Show")
        $("#locationTable").html(html).tablesorter()
        @allData = @userInputData
        if @flag > 0
          @removeMarkers()
        @getMarkersOnMap(@map)
        @emptyInputTextArea()
        @activeRelavantSectionInPopup $(".UserDetails_done")

        setTimeout (=>
          @popup.closePopup()
        ), 800
        @flag++

    $("body").on "click", ".UserDetails_prev", (e) =>
      prevSection = $(e.target).parent(@userDetailsSection).prev(@userDetailsSection)
      @activeRelavantSectionInPopup(prevSection)

    $("body").on "click", "#submitTable", (e) =>
      @removeItemsWhichNotChecked()
      @allData = @userInputData
      @removeMarkers()
      @getMarkersOnMap(@map)
      $(e.target).next("span").show().fadeOut(1000)

  activeRelavantSectionInPopup: (section) ->
    $(@userDetailsSection).removeClass("active")
    section.addClass("active")

  emptyInputTextArea: ->
    $("#inputTextArea").val(null)

  addPropInObjects: ->
    for item of @userInputData
      @userInputData[item]["id"] = item
      @userInputData[item]["Display on Map"] = "yes"

  removeItemsWhichNotChecked: ->
    $(".DataTable_displayCheck").each (i, check) =>
      display = "yes"
      unless $(check).is(":checked")
        display = "no"
      disableItem =  $(check).attr("id")
      @userInputData[disableItem]["Display on Map"] = display
      return
    return

  getHtmlForSelectingLatLng: ->
    $("#configTable").empty()
    html = ""
    html += "<tr>
          <td></td>
          <td><b>Latitude</b></td>
          <td><b>Longitude</b></td>
          <td><b>Marker Label</b></td>
        </tr>";
    keysAr = Object.keys(@userInputData[0])
    for item of keysAr
      html += "<tr><td>" + keysAr[item] + "</td>"
      html += "<td><input type='radio' name='latitude' value='" + keysAr[item] + "' /></td>"
      html += "<td><input type='radio' name='longitude' value='" + keysAr[item] + "' /></td>"
      html += "<td><input type='radio' name='markerLabel' value='" + keysAr[item] + "' /></td>"
      html += "</tr>\r\n"
    $(html).appendTo("#configTable")

  getCSVStoredDataArray: ->
    dataArray = []
    $.ajax(
      type: "GET",
      async: false,
      url: "data/sample.csv",
      dataType: "text",
      success: (csvdata) ->
        dataArray = $.csv.toObjects(csvdata)
    )
    dataArray

  getUsersDataOnPageLoad: ->
    dataArray = @getCSVStoredDataArray()
    html = @createTable.generateTable(dataArray)
    $("#defaultDataTable").html(html).tablesorter({
      sortList: [[0,0]]
    })

  getGeoLocations: ->
    valuesAr = []
    $.each @allData, (i, row) =>
      values = {
        "lat":   row[@latColumn]
        "lng":   row[@lngColumn]
        "label": row[@markLabel]
      }
      if row["Display on Map"] is "yes"
        valuesAr.push(values)
    valuesAr

  intializeDefaultMap: =>
    google.maps.event.addDomListener window, 'load', @initializeMap

  initializeMap: =>
    infoWindow = @getGeoLocations()[0]
    position = new google.maps.LatLng(infoWindow.lat, infoWindow.lng)
    mapProp =
        center: position
        zoom: 5
        mapTypeId: google.maps.MapTypeId.ROADMAP
    @map = new google.maps.Map(document.getElementById("googleMap"), mapProp)
    @getMarkersOnMap(@map)

  getMarkersOnMap: (map) ->
    @latLngArray = []
    $.each @getGeoLocations(), (i, location) =>
      marker = new google.maps.Marker
        position: new google.maps.LatLng(location.lat, location.lng),
        # animation: google.maps.Animation.BOUNCE
      marker.setMap(map)
      @latLngArray.push(marker)
      infowindow = new google.maps.InfoWindow
        content: location.label
      infowindow.open(map, marker)
    return

  removeMarkers: ->
    for mark of @latLngArray
      @latLngArray[mark].setMap(null)

class CreateTable
  constructor: (@excludeParams) ->

  generateTable: (data) ->
    requiredHtml = ""

    if typeof(data[0]) is 'undefined'
      return null

    keysAr = Object.keys(data[0])
    requiredHtml += @gettingHeader(keysAr) # getting header
    requiredHtml += @gettingRows(data, keysAr) # getting rows
    return requiredHtml

  gettingHeader: (keysAr) ->
    html = ""
    html += "<thead><tr>\r\n"
    for item of keysAr
      if $.inArray(keysAr[item], @excludeParams) is -1
        html += "<th><span>" + keysAr[item] + "</span></th>\r\n"
    html += "<th>Active/Inactive</th>"
    html += "</tr></thead>\r\n"
    return html

  gettingRows: (data, keysAr) ->
    html = ""
    html += "<tbody>"
    i = 0
    while i <= data.length - 1
      html = html + '<tr>\u000d\n'
      for key of keysAr
        item = data[i][keysAr[key]]
        if $.inArray(keysAr[key], @excludeParams) is -1
          if @checkIfValueIsUrl(item)

            if Utils.isImage(item) > -1
              html += '<td><img src=\'' + item + '\'/></td>\u000d\n'
            else
              html += '<td><a target=\'_blank\' href=\'' + item + '\'>' + item + '</a></td>\u000d\n'

          else
            html += '<td>' + item + '</td>\u000d\n'
      html += '<td><input class=\'DataTable_displayCheck\' checked type=\'checkbox\' id=\'' + i + '\'></td>'
      html += '</tr>\u000d\n'
      i++
    html += "</tbody>"
    return html

  checkIfValueIsUrl: (val) ->
    Utils.isUrlValid($.trim(val))


