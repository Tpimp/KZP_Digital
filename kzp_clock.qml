import QtQuick 2.15
import QtGraphicalEffects 1.15
Rectangle{
    id:top
    anchors.fill:parent
    //property int hoursPassed:6 // for testing
    color:"#868686"
    property var  weekDays : []
    property var  months : []
    function setArrays(locale)
    {
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
        let baseDate = new Date(Date.UTC(2017, 0, 2)); // only functions with this (poor) syntax, needs investigation
        for(var i = 0; i < 7; i++)
        {
            top.weekDays.push(baseDate.toDateString(locale).slice(0,3));
            baseDate.setDate(baseDate.getDate() + 1);
        }
        for(var j = 0; j < 12; ++j) {
            baseDate.setMonth(j);
            top.months.push(baseDate.toDateString(locale).slice(4,7));
        }
    }

    function setCompassText(offset : int) {
        if(offset < 0) {
            offset += 360;
        }
        if(offset >= 0 && offset < 90) { // north
            compassText.text = "N";
            compassText.color = "#27cbfd"
            return;
        }
        if(offset >= 90 && offset < 180) { // north
            compassText.text = "E";
            compassText.color = "#db8c0d"
            return;
        }
        if(offset >= 180 && offset < 270) { // north
            compassText.text = "S";
            compassText.color = "#00e64d"
            return;
        }
        if(offset >= 270 && offset < 360) { // north
            compassText.text = "W";
            compassText.color = "#e34aee"
            return;
        }

    }
    Connections {
        target: DeviceConnection
        function onRotationOffsetChanged(offset){top.setCompassText(offset);}
    }

    property real lastHour: 0
    property bool is24Hour: false
    property bool isAm: true
    property string dateText: ""
    Connections {
        target: AppController
        function onDraw() {
            const options = { weekday: 'long', day: 'numeric' };
            var date = new Date();
            var hours = date.getHours()  // + top.hoursPassed; // for testing
            if(top.lastHour != hours) {
                top.lastHour = hours;
                globe.currentFrame = (80 + (hours * 6)) % 180; // update the globe
                if(top.is24Hour) {  // set values for 24 hour clock
                    top.currentHour = hours;
                    top.isAm = false;
                } else {
                    if(hours >= 12) {
                        top.isAm = false;
                        if(hours > 12){
                            hours -= 12;
                        }
                    }else {
                        top.isAm = true;
                        if(hours == 0) {
                            hours = 12;
                        }
                    }
                }
                hourText.text = hours.toString().padStart(2, '0')
                // an hour went by? maybe it is a new day!
                top.dateText = top.weekDays[date.getDay()] + '  ' + date.getDate().toString().padStart(2,'0');
                monthText.text = top.months[date.getMonth()]
                yearText.text = date.getFullYear()
            }
            minuteText.text = date.getMinutes().toString().padStart(2, '0')
            secondsText.text = date.getSeconds().toString().padStart(2, '0')
            fanRPM.text = DeviceConnection.fanSpeed
            pumpDuty.text = DeviceConnection.pumpDuty
            fanIcon.rotation += DeviceConnection.fanDuty/5;
        }
    }

    FontLoader {
        id: clockFont
        source:"fonts/next-art.heavy.otf"
    }
    Rectangle{
        id:fanGlow
        height:24
        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#ffbc05";
            }
            GradientStop {
                position: 1.00;
                color: "#ffa305";
            }
        }
        radius:8
        width:(80 * DeviceConnection.fanDuty) / 100
        anchors{
            left:parent.left
            leftMargin:12
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 2
        }
    }

    Glow{
        height:28
        width:(80 * DeviceConnection.fanDuty) / 100
        radius:8
        samples:24
        color:"#eba60f"
        source:fanGlow
        anchors{
            left:parent.left
            leftMargin:14
            verticalCenter: parent.verticalCenter
        }
    }
    Image{
        id:fanIcon
        cache:false
        height:24
        width:24
        anchors{
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 0
            left:parent.left
            leftMargin:70
        }
        source:"images/fan.png"
    }
    Image{
        anchors{
            verticalCenter:parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: 2
        }
        fillMode: Image.PreserveAspectFit
        source:"images/background.png"
        height:324
        width:328
        smooth:true
    }
    // Time Text
    Text{
        id: hourText
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors{
            horizontalCenter: parent.horizontalCenter
            verticalCenter:parent.verticalCenter
            verticalCenterOffset: -60
            horizontalCenterOffset:36
        }
        color:"#ffffff"
        font.family: clockFont.name
        font.letterSpacing: 2
        font.pixelSize: 92
        font.bold: true
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect: InnerShadow{
            radius:6
            spread:.75
            samples:32
            color:"black"
            cached: false
          }
    }
    Text{
        id: monthText
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors{
            horizontalCenter: dateText.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset:-90
        }
        color:"white"
        font.family: clockFont.name
        font.pixelSize: 22
        font.letterSpacing: -1
        font.bold: true
        style:Text.Sunken
        styleColor:"black"
        layer.enabled: true
        layer.effect: InnerShadow{
            opacity:1
            spread:.7
            samples:8
            color:"black"
            cached: false
        }
    }

    Text{
        id: dateText
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors{
            verticalCenter: parent.verticalCenter
            left:parent.left
            verticalCenterOffset:-52
            leftMargin:24
        }
        color:"white"
        font.family: clockFont.name
        font.pixelSize: 22
        font.letterSpacing: -1
        font.bold: true
        text: top.dateText
        style:Text.Sunken
        styleColor:"black"
        layer.enabled: true
        layer.effect: InnerShadow{
            opacity:1
            spread:.7
            samples:8
            color:"black"
            cached: false
        }
    }
    Text{
        id: yearText
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors{
            horizontalCenter: dateText.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset:-31
        }
        color:"white"
        font.family: clockFont.name
        font.pixelSize: 14
        font.letterSpacing: -1
        font.bold: true
        text:""
        style:Text.Sunken
        styleColor:"black"
        layer.enabled: true
        layer.effect: InnerShadow{
            opacity:1
            spread:.7
            samples:8
            color:"black"
            cached: false
        }
    }



    Text{
        id: secondsText
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors{
            horizontalCenter: parent.horizontalCenter
            verticalCenter:parent.verticalCenter
            horizontalCenterOffset:126
        }
        color:"#fdaa1c"
        font.family: clockFont.name
        font.pixelSize: 34
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect: InnerShadow{
            radius:2
            spread:.75
            samples:32
            color:"black"
            cached: false
          }
    }

    // Time Text
    Text{
        id: fanRPM
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        anchors{
            left:parent.left
            leftMargin:40
            verticalCenter:parent.verticalCenter
            verticalCenterOffset: 34
        }
        color:"white"
        font.family: clockFont.name
        font.preferShaping: true
        font.pixelSize:20
        font.kerning: true
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect: InnerShadow{
            opacity:1
            spread:.7
            samples:8
            color:"black"
            cached: false
        }
    }

    Text{
        id: rpmLabel
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors{
            verticalCenter:fanRPM.verticalCenter
            verticalCenterOffset: 16
            left:parent.left
            leftMargin:82
        }
        color:"#c2b2b2"
        font.pixelSize: 10
        font.letterSpacing: 1
        font.family: clockFont.name
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect: InnerShadow{
            radius:1
            spread:.6
            samples:8
            color:"black"
            cached: false
        }
        text:"RPM"
    }
    Text{
        id: pumpDuty
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors{
            verticalCenter: parent.verticalCenter
            right:pumpIcon.left
            rightMargin:2
            verticalCenterOffset: 78
        }
        color:"white"
        font.family: clockFont.name
        font.letterSpacing: 0
        font.preferShaping: true
        font.pixelSize:14
        font.kerning: true
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect: InnerShadow{
            opacity:1
            spread:.7
            samples:8
            color:"black"
            cached: false
        }
    }
    Image{
        id:pumpIcon
        cache:false
        height:32
        width:32
        anchors{
            verticalCenter: pumpDuty.verticalCenter
            left:parent.left
            leftMargin:68
        }
        source:"images/water-pump.svg"
    }

    Text{
        id:compassText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors{
            verticalCenter: parent.verticalCenter
            left:parent.left
            leftMargin:24
            verticalCenterOffset: 70
        }
        color:"#e34aee"
        font.family: clockFont.name
        font.preferShaping: true
        font.pixelSize:12
        font.kerning: true
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect: InnerShadow{
            opacity:1
            spread:.7
            samples:8
            color:"black"
            cached: false
        }
        text:"N"
    }
    Text{
        id: dutyLabel
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors{
            horizontalCenter: pumpIcon.horizontalCenter
            horizontalCenterOffset: -8
            verticalCenter:parent.verticalCenter
            verticalCenterOffset:96
        }
        color:"#c2b2b2"
        font.pixelSize: 8
        font.letterSpacing: 0
        font.family: clockFont.name
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect: InnerShadow{
            radius:.5
            spread:.4
            samples:8
            color:"black"
            cached: false
        }
        text:"DUTY"
    }

    AnimatedImage{
        id:globe
        width:78
        height:75
        source:"images/globe.gif"
        speed:0
        currentFrame:0
        anchors{
            bottom:parent.bottom
            horizontalCenter:parent.horizontalCenter
            horizontalCenterOffset: -20
            bottomMargin:-22
        }
    }

    Rectangle{
        id: globeOverlay
        color:"transparent"
        anchors.centerIn: globe
        border.width: 3
        anchors.verticalCenterOffset: -2
        width:86
        height:86
        radius:86
        border.color: "#cccccc"
        visible: true
        Rectangle{
            radius:86
            color:"transparent"
            anchors.fill: parent
            anchors.margins: 2
            border.width: 1
        }
    }
    Text{
        id: minuteText
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors{
            horizontalCenter: parent.horizontalCenter
            verticalCenter:parent.verticalCenter
            verticalCenterOffset: 60
            horizontalCenterOffset:32
        }
        color:"#ff8800"
        font.family: clockFont.name
        font.letterSpacing: 2
        font.pixelSize: 92
        font.bold: true
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect:  InnerShadow{
            opacity:1
            anchors.fill: minuteText
            radius:6
            spread:.75
            samples:32
            color:"black"
            cached: false
            source:minuteText

          }

    }

    Text {
        id: amLabel
        color:top.isAm ? "white":"#5c5a5a"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
        font.letterSpacing: 1
        anchors{
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            horizontalCenterOffset: 0;
            verticalCenterOffset: 0;
        }
        font.bold:true
        font.family: clockFont.name
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect: InnerShadow{
            opacity:1
            spread:.7
            samples:8
            color:"black"
            cached: false
          }
        text:"AM"
    }
    Text {
        id: pmLabel
        color: top.isAm ? "#5c5a5a":"white"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
        font.letterSpacing: 1
        anchors{
            horizontalCenter: parent.horizontalCenter
            verticalCenter: amLabel.verticalCenter
            horizontalCenterOffset: 34;
        }
        font.bold:true
        font.family: clockFont.name
        text:"PM"
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect: InnerShadow{
            opacity:1
            spread:.7
            samples:8
            color:"black"
            cached: false
          }
    }
    Text {
        id: tfHourLabel
        color: top.is24Hour ? "white":"#5c5a5a"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
        font.letterSpacing: 1
        anchors{
            horizontalCenter: parent.horizontalCenter
            verticalCenter: amLabel.verticalCenter
            horizontalCenterOffset: 72;
        }
        font.bold:true
        font.family: clockFont.name
        text:"H24"
        style:Text.Outline
        styleColor: "#000000"
        layer.enabled: true
        layer.effect: InnerShadow{
            opacity:1
            spread:.7
            samples:8
            color:"black"
            cached: false
          }
    }
    Component.onCompleted: {
        top.setArrays(Qt.locale().name);
        const options = { weekday: 'long', day: 'numeric' };
        var date = new Date();
        var hours = date.getHours()  // + top.hoursPassed; // for testing
        top.lastHour = hours;
        globe.currentFrame = (80 + (hours * 6)) % 180; // update the globe
        if(top.is24Hour) {  // set values for 24 hour clock
            top.currentHour = hours;
            top.isAm = false;
        } else {
            if(hours >= 12) {
                top.isAm = false;
                if(hours > 12){
                    hours -= 12;
                }
            }else {
                top.isAm = true;
                if(hours == 0) {
                    hours = 12;
                }
            }
        }
        hourText.text = hours.toString().padStart(2, '0')
        // an hour went by? maybe it is a new day!
        top.dateText = top.weekDays[date.getDay()] + '  ' + date.getDate().toString().padStart(2,'0');
        monthText.text = top.months[date.getMonth()]
        yearText.text = date.getFullYear()
        minuteText.text = date.getMinutes().toString().padStart(2, '0')
        secondsText.text = date.getSeconds().toString().padStart(2, '0')
        fanRPM.text = DeviceConnection.fanSpeed
        pumpDuty.text = DeviceConnection.pumpDuty
        top.setCompassText(DeviceConnection.rotationOffset);
        AppController.setFrameDelay(920);
    }

}
