//
//  CryptoBackground.swift
//  Cloud Crypto iOS App
//
//  Decorative background inspired by the Cloud Crypto Android app's
//  circuit-board / crypto aesthetic.
//

import SwiftUI

struct CryptoBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        AppColors.background,
                        Color(red: 0x10 / 255.0, green: 0x22 / 255.0, blue: 0x36 / 255.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Canvas { context, size in
                    drawCircuitTraces(context: context, size: size)
                    drawCoinOutlines(context: context, size: size)
                }
                .blendMode(.screen)
                .opacity(0.55)

                // Ambient glow spots
                glow(at: CGPoint(x: proxy.size.width * 0.12, y: proxy.size.height * 0.18),
                     color: AppColors.primary.opacity(0.35),
                     radius: proxy.size.width * 0.45)
                glow(at: CGPoint(x: proxy.size.width * 0.88, y: proxy.size.height * 0.78),
                     color: AppColors.secondary.opacity(0.30),
                     radius: proxy.size.width * 0.50)
                glow(at: CGPoint(x: proxy.size.width * 0.50, y: proxy.size.height * 0.48),
                     color: AppColors.tertiary.opacity(0.18),
                     radius: proxy.size.width * 0.55)
            }
        }
        .ignoresSafeArea()
    }

    private func glow(at point: CGPoint, color: Color, radius: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color, color.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: radius
                )
            )
            .frame(width: radius * 2, height: radius * 2)
            .position(point)
            .blendMode(.plusLighter)
    }

    private func drawCircuitTraces(context: GraphicsContext, size: CGSize) {
        let teal = Color(.sRGB, red: 0, green: 0.83, blue: 0.67, opacity: 0.55)
        let purple = Color(.sRGB, red: 0.49, green: 0.30, blue: 1.0, opacity: 0.45)
        let blue = Color(.sRGB, red: 0.23, green: 0.51, blue: 0.96, opacity: 0.40)

        // Horizontal bus lines
        let busYs: [CGFloat] = [0.18, 0.40, 0.62, 0.84]
        for (i, ratio) in busYs.enumerated() {
            let y = size.height * ratio
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            let color = [teal, purple, blue, teal][i % 3]
            context.stroke(path, with: .color(color), lineWidth: 1.0)
        }

        // Vertical bus lines
        let busXs: [CGFloat] = [0.20, 0.50, 0.80]
        for (i, ratio) in busXs.enumerated() {
            let x = size.width * ratio
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            let color = [purple, teal, blue][i % 3]
            context.stroke(path, with: .color(color), lineWidth: 1.0)
        }

        // Angled trace wires with right-angle bends
        let bends: [(CGPoint, CGPoint, CGPoint)] = [
            (CGPoint(x: size.width * 0.05, y: size.height * 0.30),
             CGPoint(x: size.width * 0.30, y: size.height * 0.30),
             CGPoint(x: size.width * 0.30, y: size.height * 0.55)),
            (CGPoint(x: size.width * 0.70, y: size.height * 0.10),
             CGPoint(x: size.width * 0.70, y: size.height * 0.32),
             CGPoint(x: size.width * 0.95, y: size.height * 0.32)),
            (CGPoint(x: size.width * 0.10, y: size.height * 0.70),
             CGPoint(x: size.width * 0.45, y: size.height * 0.70),
             CGPoint(x: size.width * 0.45, y: size.height * 0.95)),
            (CGPoint(x: size.width * 0.60, y: size.height * 0.60),
             CGPoint(x: size.width * 0.85, y: size.height * 0.60),
             CGPoint(x: size.width * 0.85, y: size.height * 0.92))
        ]
        for (i, segment) in bends.enumerated() {
            var path = Path()
            path.move(to: segment.0)
            path.addLine(to: segment.1)
            path.addLine(to: segment.2)
            let color = [teal, purple, blue][i % 3]
            context.stroke(path, with: .color(color), lineWidth: 1.2)

            // Connection nodes with halos at endpoints
            for nodePoint in [segment.0, segment.2] {
                let nodeRect = CGRect(x: nodePoint.x - 3, y: nodePoint.y - 3, width: 6, height: 6)
                context.fill(Path(ellipseIn: nodeRect), with: .color(color))
                let halo = CGRect(x: nodePoint.x - 7, y: nodePoint.y - 7, width: 14, height: 14)
                context.stroke(Path(ellipseIn: halo), with: .color(color.opacity(0.5)), lineWidth: 0.8)
            }
        }
    }

    private func drawCoinOutlines(context: GraphicsContext, size: CGSize) {
        struct Coin {
            let x: CGFloat
            let y: CGFloat
            let radius: CGFloat
            let color: Color
        }
        let coins: [Coin] = [
            Coin(x: 0.08, y: 0.08, radius: 22, color: AppColors.bitcoin.opacity(0.7)),
            Coin(x: 0.92, y: 0.12, radius: 18, color: AppColors.primary.opacity(0.7)),
            Coin(x: 0.18, y: 0.92, radius: 26, color: AppColors.secondary.opacity(0.7)),
            Coin(x: 0.78, y: 0.95, radius: 20, color: AppColors.tertiary.opacity(0.7)),
            Coin(x: 0.50, y: 0.06, radius: 16, color: AppColors.primary.opacity(0.55))
        ]
        for coin in coins {
            let center = CGPoint(x: size.width * coin.x, y: size.height * coin.y)
            let outer = CGRect(x: center.x - coin.radius, y: center.y - coin.radius,
                               width: coin.radius * 2, height: coin.radius * 2)
            let inner = outer.insetBy(dx: 4, dy: 4)
            context.stroke(Path(ellipseIn: outer), with: .color(coin.color), lineWidth: 1.2)
            context.stroke(Path(ellipseIn: inner), with: .color(coin.color.opacity(0.6)), lineWidth: 0.8)
        }
    }
}

#Preview {
    CryptoBackground()
}
