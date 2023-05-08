//
//  ToastPresentable.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import UIKit

protocol AlertPresentable {
    func presentToastMessage(_ toast: ToastMessage)
}

extension AlertPresentable {
    func presentToastMessage(_ toast: ToastMessage) {
        let toastViewController = UIViewController()
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let currentWindowScene = UIApplication.shared.keyWindowScene
        else {
            return
        }
        
        sceneDelegate.toastWindow = UIWindow(windowScene: currentWindowScene)
        guard let window = sceneDelegate.toastWindow else { return }
        
        window.windowLevel = UIWindow.Level.alert
        window.rootViewController = toastViewController
        window.makeKeyAndVisible()
        
        let view = toastViewController.view ?? UIView()
        view.backgroundColor = .clear
        
        let toastView = ToastView(toast)
        layoutToast(toastView, on: view)
        let originalTransform = toastView.transform
        let translatedTransform = originalTransform.translatedBy(x: 0.0, y: -76)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: { toastView.transform = translatedTransform },
                       completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.25, delay: 0,
                               options: [.curveLinear],
                               animations: { toastView.alpha = 0 },
                               completion: { _ in
                    toastView.removeFromSuperview()
                    sceneDelegate.toastWindow = nil
                })
            }
        })
    }

    private func layoutToast(_ toast: ToastView, on view: UIView) {
        view.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toast.heightAnchor.constraint(equalToConstant: 52),
            toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
    }
}
