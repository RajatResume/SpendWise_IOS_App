// Team Members:
// - Venkatesh Talasila - vtalasi@iu.edu
// - Rajat Madhav Sawant - rsawant@iu.edu

// Final Project iOS App Name: SpendWise

// IU GitHub Submission Date: May 6, 2025

import UIKit
import Accelerate

class BarChartView: UIView {
    private var values: [CGFloat] = []
    private var labels: [String] = []
    private var colors: [UIColor] = []

    private let barWidth: CGFloat = 40
    private let spacing: CGFloat = 30
    private let topPadding: CGFloat = 20
    private let leftPadding: CGFloat = 40
    private let bottomPadding: CGFloat = 40
    private let yAxisSteps = 5

    func setData(values: [CGFloat], labels: [String], colors: [UIColor]) {
        self.values = values
        self.labels = labels
        self.colors = colors
        setNeedsDisplay()
    }

    func requiredWidth() -> CGFloat {
        return leftPadding + CGFloat(values.count) * (barWidth + spacing) + spacing * 2
    }

    private func optimizedMaxValue() -> CGFloat {
        guard !values.isEmpty else { return 1 }
        let floatValues = values.map { Float($0) }
        var maxValue: Float = 0
        vDSP_maxv(floatValues, 1, &maxValue, vDSP_Length(values.count))
        return CGFloat(maxValue) * 1.1
    }

    override func draw(_ rect: CGRect) {
        guard !values.isEmpty else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Clear existing layers (for animation redraws)
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        // White background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)

        let maxVal = optimizedMaxValue()
        let height = bounds.height - topPadding - bottomPadding
        let originY = bounds.height - bottomPadding

        let stepValue = maxVal / CGFloat(yAxisSteps)
        let labelFont = UIFont.systemFont(ofSize: 10)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right

        for i in 0...yAxisSteps {
            let yVal = stepValue * CGFloat(i)
            let yPos = originY - (yVal / maxVal * height)

            // Grid
            context.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.4).cgColor)
            context.setLineWidth(0.5)
            context.move(to: CGPoint(x: leftPadding, y: yPos))
            context.addLine(to: CGPoint(x: bounds.width, y: yPos))
            context.strokePath()

            // Label
            let label = String(format: "%.0f", yVal)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: labelFont,
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            label.draw(in: CGRect(x: 0, y: yPos - 8, width: leftPadding - 4, height: 16), withAttributes: attributes)
        }

        for (index, value) in values.enumerated() {
            let barHeight = value / maxVal * height
            let x = leftPadding + spacing + CGFloat(index) * (barWidth + spacing)
            let y = originY - barHeight

            // Animate bar with shape layer
            let barPath = UIBezierPath(rect: CGRect(x: x, y: originY, width: barWidth, height: 0))
            let barLayer = CAShapeLayer()
            barLayer.path = barPath.cgPath
            barLayer.fillColor = colors[index].cgColor
            layer.addSublayer(barLayer)

            let anim = CABasicAnimation(keyPath: "path")
            anim.fromValue = barPath.cgPath
            anim.toValue = UIBezierPath(rect: CGRect(x: x, y: y, width: barWidth, height: barHeight)).cgPath
            anim.duration = 0.7
            anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            barLayer.path = UIBezierPath(rect: CGRect(x: x, y: y, width: barWidth, height: barHeight)).cgPath
            barLayer.add(anim, forKey: "grow")

            // Value label
            let valueLabel = String(format: "$%.0f", value)
            let valueAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .medium),
                .foregroundColor: UIColor.black
            ]
            let valueSize = valueLabel.size(withAttributes: valueAttributes)
            let valuePoint = CGPoint(x: x + (barWidth - valueSize.width)/2, y: y - valueSize.height - 2)
            valueLabel.draw(at: valuePoint, withAttributes: valueAttributes)

            // Month label
            let monthLabel = labels[index] as NSString
            let monthRect = CGRect(x: x - 10, y: originY + 2, width: barWidth + 20, height: 14)
            monthLabel.draw(in: monthRect, withAttributes: [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.black
            ])
        }
    }
}
