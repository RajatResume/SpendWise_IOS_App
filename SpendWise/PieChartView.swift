// Team Members:
// - Venkatesh Talasila - vtalasi@iu.edu
// - Rajat Madhav Sawant - rsawant@iu.edu

// Final Project iOS App Name: SpendWise

// IU GitHub Submission Date: May 6, 2025

import UIKit

class PieChartView: UIView {
    var segments: [(value: CGFloat, color: UIColor, label: String)] = [] {
        didSet {
            layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard !segments.isEmpty else { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY - 60)
        let radius = min(bounds.width, bounds.height) * 0.35
        var startAngle: CGFloat = -.pi / 2
        let total = segments.reduce(0) { $0 + $1.value }

        for segment in segments {
            let endAngle = startAngle + 2 * .pi * (segment.value / total)
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

            let sliceLayer = CAShapeLayer()
            sliceLayer.path = path.cgPath
            sliceLayer.fillColor = segment.color.cgColor
            layer.addSublayer(sliceLayer)

            // Pop-in animation
            let anim = CABasicAnimation(keyPath: "transform.scale")
            anim.fromValue = 0.0
            anim.toValue = 1.0
            anim.duration = 0.5
            anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            sliceLayer.add(anim, forKey: "pop")

            startAngle = endAngle
        }

        // Legend
        let legendX = center.x - radius
        var legendY = center.y + radius + 20
        let legendRectSize = CGSize(width: 16, height: 16)
        let spacing: CGFloat = 8
        let font = UIFont.systemFont(ofSize: 12)

        for segment in segments {
            let colorRect = CGRect(x: legendX, y: legendY, width: legendRectSize.width, height: legendRectSize.height)
            let colorBox = UIBezierPath(rect: colorRect)
            let colorLayer = CAShapeLayer()
            colorLayer.path = colorBox.cgPath
            colorLayer.fillColor = segment.color.cgColor
            layer.addSublayer(colorLayer)

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black
            ]
            let label = segment.label as NSString
            let textPoint = CGPoint(x: legendX + legendRectSize.width + spacing, y: legendY)
            label.draw(at: textPoint, withAttributes: attributes)

            legendY += legendRectSize.height + spacing
        }
    }
}
