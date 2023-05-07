//
//  Router.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import UIKit

protocol Routable: AnyObject {
    func setRootViewController(viewController: Presentable)
    
    func push(_ module: Presentable?)
    func push(_ module: Presentable?, animated: Bool)
    func push(_ module: Presentable?, animated: Bool, dismissCompletion: (() -> Void)?)
    
    func pop(_ module: Presentable?)
    func pop(_ module: Presentable?, animated: Bool)
    func pop(_ module: Presentable?, animated: Bool, dismissCompletion: (() -> Void)?)
    
    func present(_ module: Presentable?)
    func present(_ module: Presentable?, dismissCompletion: (() -> Void)?)
    func present(_ module: Presentable?, animated: Bool)
    func present(_ module: Presentable?, presentationStyle: UIModalPresentationStyle)
    func present(_ module: Presentable?, animated: Bool, presentationStyle: UIModalPresentationStyle, dismissCompletion: (() -> Void)?)
    func dismissModule(_ module: Presentable?)
    func dismissModule(_ module: Presentable?, completion: (() -> Void)?)
    func dismissModule(_ module: Presentable?, animated: Bool, completion: (() -> Void)?)
}

final class Router: NSObject {
    weak var delegate: RouterDelegate?
    private var completions: [UIViewController: (() -> Void)?]
    private var presentingViewController: Presentable?
    
    init(routerDelegate: RouterDelegate) {
        self.delegate = routerDelegate
        self.completions = [:]
    }
}

extension Router: Routable {
    func setRootViewController(viewController: Presentable) {
        presentingViewController = viewController
        delegate?.setRootViewController(presentingViewController)
    }
    
    func push(_ module: Presentable?) {
        push(module, animated: true, dismissCompletion: nil)
    }
    
    func push(_ module: Presentable?, animated: Bool) {
        push(module, animated: animated, dismissCompletion: nil)
    }
    
    func push(_ module: Presentable?, animated: Bool, dismissCompletion: (() -> Void)? = nil) {
        guard let controller = module?.toPresent() else { return }
        
        controller.presentationController?.delegate = self
        guard let navController = presentingViewController?.toPresent() as? UINavigationController else { return }
        
        navController.pushViewController(controller, animated: animated)
        presentingViewController = controller
        addCompletion(dismissCompletion, for: controller)
    }

    func pop(_ module: Presentable?) {
        pop(module, animated: true, dismissCompletion: nil)
    }
    
    func pop(_ module: Presentable?, animated: Bool) {
        pop(module, animated: animated, dismissCompletion: nil)
    }
    
    func pop(_ module: Presentable?, animated: Bool, dismissCompletion: (() -> Void)? = nil) {
        guard let controller = module?.toPresent() else { return }
        
        deleteCompletion(for: presentingViewController?.toPresent())
        presentingViewController = controller.presentingViewController
        guard let navController = presentingViewController?.toPresent() as? UINavigationController else { return }
        navController.popViewController(animated: animated)
        deleteCompletion(for: presentingViewController?.toPresent())
    }
    
    func present(_ module: Presentable?, dismissCompletion: (() -> Void)? = nil) {
        present(module, animated: true, presentationStyle: .automatic, dismissCompletion: dismissCompletion)
    }
    
    func present(_ module: Presentable?) {
        present(module, animated: true, presentationStyle: .automatic)
    }
    
    func present(_ module: Presentable?, animated: Bool) {
        present(module, animated: animated, presentationStyle: .automatic)
    }
    
    func present(_ module: Presentable?, presentationStyle: UIModalPresentationStyle) {
        present(module, animated: true, presentationStyle: presentationStyle)
    }
    
    func present(_ module: Presentable?, animated: Bool, presentationStyle: UIModalPresentationStyle, dismissCompletion: (() -> Void)? = nil) {
        guard let controller = module?.toPresent() else { return }
        
        controller.modalPresentationStyle = presentationStyle
        controller.presentationController?.delegate = self
        presentingViewController?.toPresent()?.present(controller, animated: animated, completion: nil)
        presentingViewController = controller
        addCompletion(dismissCompletion, for: controller)
    }
    
    func dismissModule(_ module: Presentable?) {
        dismissModule(module, animated: true, completion: nil)
    }
    
    func dismissModule(_ module: Presentable?, completion: (() -> Void)?) {
        dismissModule(module, animated: true, completion: completion)
    }
    
    func dismissModule(_ module: Presentable?, animated: Bool, completion: (() -> Void)?) {
        guard let controller = module?.toPresent() else { return }
        deleteCompletion(for: presentingViewController?.toPresent())
        presentingViewController = controller.presentingViewController
        presentingViewController?.toPresent()?.dismiss(animated: true, completion: completion)
    }
}

extension Router: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presentingViewController = presentationController.presentingViewController
        runCompletion(for: presentationController.presentedViewController)
    }
}

private extension Router {
    func addCompletion(_ completion: (() -> Void)?, for controller: UIViewController?) {
        if let completion, let controller {
            completions[controller] = completion
        }
    }
    
    func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion?()
        completions.removeValue(forKey: controller)
    }
    
    func deleteCompletion(for controller: UIViewController?) {
        guard let controller else { return }
        completions.removeValue(forKey: controller)
    }
}
