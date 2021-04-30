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
    var xMax = Int(Date().addingTimeInterval(60).timeIntervalSince1970)
    var yMin = -5
    var yMax = 50
    
    @IBOutlet var hostView: CPTGraphHostingView!
    @IBOutlet var mqttLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMQTT()
        setupGraph()
    }
    
    private func setupMQTT() {
        mqttService.subscribe(to: "temperature")
        mqttService.client.addMessageListener { _, message, _ in
            print(message)
            if  let payload = message.payload,
                let json = payload.getString(at: payload.readerIndex, length: payload.readableBytes) {
                if let data = json.data(using: .utf8),
                   let tempData : TempData = try? self.jsonDecoder.decode(TempData.self, from: data){
                    print(tempData)
                    DispatchQueue.main.async {
                        self.mqttLbl.text = """
                        --\(tempData.dateTime.shortFormat())--
                        Ambient temp: \(tempData.ambientTemp)
                        Object  temp: \(tempData.objectTemp)
                    """
                        self.plotTemp(tempData: tempData)
                    }
                    
                }
            }
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

        let title = "Temperature data"
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
            x.labelTextStyle = axisTextStyle
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
        let plotLineStile = CPTMutableLineStyle()
        plotLineStile.lineJoin = .round
        plotLineStile.lineCap = .round
        plotLineStile.lineWidth = 2
        plotLineStile.lineColor = CPTColor.white()
        tempPlot.dataLineStyle = plotLineStile
        tempPlot.curvedInterpolationOption = .catmullCustomAlpha
        tempPlot.interpolation = .curved
        tempPlot.identifier = "coreplot-graph" as NSCoding & NSCopying & NSObjectProtocol
        tempPlot.dataSource = (self as CPTPlotDataSource)
        tempPlot.delegate = (self as CALayerDelegate)
        graph.add(tempPlot, to: graph.defaultPlotSpace)
        
        hostView.hostedGraph = graph
        
    }
    
    private func plotTemp(tempData: TempData){
        // setup animation
        guard let graph = hostView.hostedGraph,
              let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        
        var prevMaxTimeInt = xMax
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

