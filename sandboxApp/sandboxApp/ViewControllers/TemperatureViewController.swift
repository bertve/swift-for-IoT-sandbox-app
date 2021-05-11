//
//  TemperatureViewController.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 17/04/2021.
//

import UIKit
import CorePlot

class TemperatureViewController: UIViewController{
    
    private let rpiService = RPIService()
    private let mqttService = MQTTService()
    private let jsonDecoder = JSONDecoder()
    
    var tempDataCollection : [TempData] = []
    var currentIndex: Int!
    var xMin = Int(Date().timeIntervalSince1970)
    var xMax = Int(Date().addingTimeInterval(20).timeIntervalSince1970)
    var yMin = 20
    var yMax = 45
    
    
    @IBOutlet var hostView: CPTGraphHostingView!
    @IBOutlet var mqttLbl: UILabel!
    @IBOutlet var declineBtn: UIButton!
    @IBOutlet var acceptBtn: UIButton!
    
    private var smnStandigInFrontOfDoor = false
    override func viewDidLoad() {
        super.viewDidLoad()
        declineBtn.isEnabled = false
        acceptBtn.isEnabled = false
        setupMQTT()
        setupGraph()
    }
    
    private func setupMQTT() {
        mqttService.subscribe(to: "temperature")
        mqttService.client.addMessageListener { _, message, _ in
            if  let payload = message.payload,
                let json = payload.getString(at: payload.readerIndex, length: payload.readableBytes) {
                    if let data = json.data(using: .utf8),
                       let tempData : TempData = try? self.jsonDecoder.decode(TempData.self, from: data){
                            DispatchQueue.main.async {
                                self.updateUI(with: tempData)
                            }
                        
                    }
            }
        }
    }
    
    private func updateUI(with tempData: TempData){
        if let lastTempdata = tempDataCollection.last {
            // when there is a break in between the time of delivery you have to enable evaluation (normally 0.5s  in between)
            if lastTempdata.dateTime.addingTimeInterval(1) < tempData.dateTime {
                print("break")
                enableEvaluation()
            }
                
        } else {
            // no data yet so enable evalutation
            enableEvaluation()
        }
                
        if smnStandigInFrontOfDoor {
            self.mqttLbl.textColor = tempData.isFeverDetected() ? .red : .white
            self.mqttLbl.text = """
            --\(tempData.dateTime.shortFormat())--
            Ambient temp: \(tempData.ambientTemp)
            Object  temp: \(tempData.objectTemp)
        """
            self.plotTemp(tempData: tempData)
        }

    }
    
    private func setupGraph() {
        let graph = CPTXYGraph(frame: hostView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        hostView.hostedGraph = graph
        graph.backgroundColor = UIColor.black.cgColor
        graph.paddingBottom = 40.0
        graph.paddingLeft = 40.0
        graph.paddingTop = 30.0
        graph.paddingRight = 15.0
        
        
        // set title
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.white()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 20.0
        titleStyle.textAlignment = .center
        graph.titleTextStyle = titleStyle
        let title = "Temperature data (C°)"
        graph.title = title
        graph.titlePlotAreaFrameAnchor = .top
        graph.titleDisplacement = CGPoint(x: 0.0, y: 0.0)
        
        // setup plot space
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal:CPTDecimalFromInteger(xMin), lengthDecimal: CPTDecimalFromInteger(xMax - xMin))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromInteger(yMin), lengthDecimal: CPTDecimalFromInteger(yMax - yMin))
        
        // setup axis
        let axisSet = graph.axisSet as! CPTXYAxisSet
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.white()
        axisTextStyle.fontName = "HelveticaNeue-Bold"
        axisTextStyle.fontSize = 10.0
        axisTextStyle.textAlignment = .center
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor.white()
        lineStyle.lineWidth = 5
        
        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 20
            x.minorTicksPerInterval = 5
            x.labelTextStyle = nil
            x.axisLineStyle = lineStyle
            x.axisConstraints = CPTConstraints(lowerOffset: 0.0)
            x.delegate = self
        }
        
        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 5
            y.minorTicksPerInterval = 5
            y.labelTextStyle = axisTextStyle
            y.alternatingBandFills = [CPTFill(color: CPTColor.init(componentRed: 255, green: 255, blue: 255, alpha: 0.03)),CPTFill(color: CPTColor.black())]
            y.axisLineStyle = lineStyle
            y.axisConstraints = CPTConstraints(lowerOffset: 0.0)
            y.delegate = self
        }
        
        // setup line plot
        let tempPlot = CPTScatterPlot()
        let plotLineStyle = CPTMutableLineStyle()
        plotLineStyle.lineJoin = .round
        plotLineStyle.lineCap = .round
        plotLineStyle.lineWidth = 1
        plotLineStyle.lineColor = CPTColor.white()
        tempPlot.dataLineStyle = plotLineStyle
        tempPlot.curvedInterpolationOption = .catmullCustomAlpha
        tempPlot.interpolation = .curved
        tempPlot.identifier = "coreplot-graph" as NSCoding & NSCopying & NSObjectProtocol
        tempPlot.dataSource = (self as CPTPlotDataSource)
        tempPlot.delegate = (self as CALayerDelegate)
        graph.add(tempPlot, to: graph.defaultPlotSpace)
        
        // add to host
        hostView.hostedGraph = graph
    }
    
    private func plotTemp(tempData: TempData){
        guard let graph = hostView.hostedGraph,
              let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        
        // set color if fever
        if tempData.isFeverDetected() {
            if let plot = graph.plot(withIdentifier: "coreplot-graph" as NSCoding & NSCopying & NSObjectProtocol) as? CPTScatterPlot {
                let plotLineStyle = CPTMutableLineStyle()
                plotLineStyle.lineJoin = .round
                plotLineStyle.lineCap = .round
                plotLineStyle.lineWidth = 1
                plotLineStyle.lineColor = CPTColor.red()
                plot.dataLineStyle = plotLineStyle
            }
        } else {
            if let plot = graph.plot(withIdentifier: "coreplot-graph" as NSCoding & NSCopying & NSObjectProtocol) as? CPTScatterPlot {
                let plotLineStyle = CPTMutableLineStyle()
                plotLineStyle.lineJoin = .round
                plotLineStyle.lineCap = .round
                plotLineStyle.lineWidth = 1
                plotLineStyle.lineColor = CPTColor.white()
                plot.dataLineStyle = plotLineStyle
            }
        }
        
        // setup animation
        var prevMaxTimeInt = xMax
        // if there is a previous measurement set previousmaxtime
        if let previousTempData = tempDataCollection.last,
           Int(previousTempData.dateTime.timeIntervalSince1970) > xMax {
            prevMaxTimeInt = Int(previousTempData.dateTime.timeIntervalSince1970)
        }
        
        var maxTimeInt = xMax
        if Int(tempData.dateTime.timeIntervalSince1970) > xMax {
            maxTimeInt = Int(tempData.dateTime.timeIntervalSince1970)
        }
        
        let oldRange = CPTPlotRange(locationDecimal:CPTDecimalFromInteger(xMin), lengthDecimal: CPTDecimalFromInteger(prevMaxTimeInt - xMin))
        let newRange =  CPTPlotRange(locationDecimal: CPTDecimalFromInteger(xMin), lengthDecimal: CPTDecimalFromInteger(maxTimeInt - xMin))
        CPTAnimation.animate(plotSpace, property: "xRange", from: oldRange, to: newRange, duration: 1)
        
        tempDataCollection.append(tempData)
        graph.reloadData()
    }
    
    @IBAction func declineBtnPushed(_ sender: UIButton) {
        publishEvaluation(false)
    }
    
    @IBAction func acceptBtnPushed(_ sender: UIButton) {
        publishEvaluation(true)
    }
    
    private func publishEvaluation(_ accepted :Bool){
        mqttService.publish(to: "door", with: DoorRequestModel(openDoor: accepted))
        disableEvaluation()
    }
    
    private func enableEvaluation() {
        // new measurement new starting point graph
        self.tempDataCollection.removeAll()
        let graph = hostView.hostedGraph!
        graph.reloadData()
        let newXMinDate = Date()
        xMin = Int(newXMinDate.timeIntervalSince1970)
        // standard implementation
        smnStandigInFrontOfDoor = true
        declineBtn.isEnabled = true
        acceptBtn.isEnabled = true
    }
    
    private func disableEvaluation(){
        self.smnStandigInFrontOfDoor = false
        self.acceptBtn.isEnabled = false
        self.declineBtn.isEnabled = false
        self.mqttLbl.text = "No person at the door"
    }
    
}

extension TemperatureViewController: CPTScatterPlotDataSource, CPTScatterPlotDelegate {
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(self.tempDataCollection.count)
    }

    func scatterPlot(_ plot: CPTScatterPlot, plotSymbolWasSelectedAtRecord idx: UInt, with event: UIEvent) {
        
    }

     func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
        
       switch CPTScatterPlotField(rawValue: Int(field))! {
        
            case .X:
                return Int(self.tempDataCollection[Int(record)].dateTime.timeIntervalSince1970)

            case .Y:
                return self.tempDataCollection[Int(record)].objectTemp
            
            default:
                return 0
       }
        
    }
}

extension Date {
    func shortFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: self)
    }
}

