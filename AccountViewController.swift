//
//  AccountViewController.swift
//  XcodeLoginExample
//
//  Created by Mahesh Rapaka on 9/1/17.
//  Copyright © 2017 Belal Khan. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
class AccountViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{
 let defaultValues = UserDefaults.standard
    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var secondtableview: UITableView!
    
    @IBOutlet weak var thirdtableView: UITableView!
   
    var AccountDetailsArray = [AccountDetails]()
    let dateF = DateFormatter()
    var AccountDetailsInfoArray = [AccountDetailsInfo]()
     var accountdetailsJSON:NSDictionary = [:]
    var recentpaymentDetailsArray:[NSDictionary] = []
    var subdetailsArray:[NSDictionary]=[]
     var recentpaymentDetailsInfoArray = [RecentPayments]()
     var subscriptionsarray = [SubscriptionDet]()
    var dtToday = Date();
    var yest = Date()
    var tomo = Date()
    var lbl :String = " "
    
    @IBAction func changeLabel(_ sender: Any) {        
let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popup") as! POPUPViewController
   
        popvc.modalTransitionStyle = .crossDissolve
        popvc.modalPresentationStyle = .overCurrentContext
        self.addChildViewController(popvc)
        popvc.view.backgroundColor = UIColor.gray
        popvc.calendarView.commitCalendarViewUpdate()
        popvc.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 100, height :self.view.frame.height - 200)
        let centre : CGPoint = CGPoint(x: self.view.center.x, y: self.view.center.y)
        popvc.view.center = centre
        self.view.addSubview(popvc.view)
        popvc.didMove(toParentViewController: self)
    }
   
    @IBOutlet weak var dateLabel: UIButton!
    @IBAction func viewMore(_ sender: Any) {
        let recPaymentsViewController = self.storyboard?.instantiateViewController(withIdentifier: "recpay") as! RecentPaymentsViewController
         recPaymentsViewController.recentpaymentDetailsInfoArray=self.recentpaymentDetailsInfoArray
        self.navigationController?.pushViewController(recPaymentsViewController, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    var retid : String = ""
    override func awakeFromNib() {
         getAccountDetails()
        
    }
    
    override func viewDidLoad() {
        
    
  
    firstTableView.estimatedRowHeight=400
         //   getRecentPayments()
        // getSubscriptionDetails(monthLbl: lbl)
        let months = dateF.monthSymbols
        let calendar2 = Calendar.current
        let components2 = calendar2.dateComponents([.day , .month , .year], from: dtToday)
        let year =  (components2.year)!
        let month = (components2.month)!
        let day = (components2.day)!
        let mf = (String((months?[month-1])!))!
        self.lbl = (String(day)+mf+String(year))
        var displabl = (String(day)+" "+mf+" "+String(year))
        print("DLLLLLLLLLLL today",lbl)
        self.dateLabel.setTitle(displabl, for: .normal)
        getSubscriptionDetails(monthLbl: self.lbl)
        super.viewDidLoad()
    }
   
    @IBAction func loadNextDay(_ sender: Any) {
               let calendar = Calendar.current
        var components = DateComponents()
        let months = dateF.monthSymbols
        components.setValue(1, for: .day)
        
        tomo = calendar.date(byAdding: components, to: dtToday)!
        
        let calendar2 = NSCalendar.current
        let components2 = calendar2.dateComponents([.day , .month , .year], from: tomo as Date)
       
        let year =  (components2.year)!
        let month = (components2.month)!
        let day = (components2.day)!
        let mf = (String((months?[month-1])!))!
        self.lbl = (String(day)+mf+String(year))
        var displabl = (String(day)+" "+mf+" "+String(year))
        print("DLLLLLLLLLLL too",lbl)
         self.dateLabel.setTitle(displabl, for: .normal)
        getSubscriptionDetails(monthLbl: self.lbl)
         self.dtToday = tomo
    }
    
    
    
    @IBAction func loadPrevDay(_ sender: Any) {
      
        let calendar = Calendar.current
        var components = DateComponents()
        let months = dateF.monthSymbols
        components.setValue(-1, for: .day)
    
         yest = calendar.date(byAdding: components, to: self.dtToday)!
        
        let calendar2 = Calendar.current
        let components2 = calendar2.dateComponents([.day , .month , .year], from: yest as Date)
        self.dtToday = yest
        let year =  (components2.year)!
        let month = (components2.month)!
        let day = (components2.day)!
        let mf = (String((months?[month-1])!))!
        self.lbl = (String(day)+mf+String(year))
        let displabl = (String(day)+" "+mf+" "+String(year))
        print("DLLLLLLLLLLL yest",lbl)
        //getSubscriptionDetails(monthLbl: self.lbl)
        self.dateLabel.setTitle(displabl, for: .normal)
        
        
    }
    
    func getAccountDetails()
    {
        print("In account details")
       AccountDetailsArray=[AccountDetails]()
        AccountDetailsInfoArray=[AccountDetailsInfo]()
        let urlconst = "https://nnj-dairyplus-pd-api.azurewebsites.net/api/"
        let URL_ACCOUNT_DETAILS = urlconst + "customer_account/all"
        print("URL_ACCOUNT_DETAILS",URL_ACCOUNT_DETAILS)
        if let Authorization=defaultValues.string(forKey: "Authorization"){
            let headers: HTTPHeaders = [
                "Authorization": Authorization,
                "Content-Type": "application/json"
            ]
            print("header",headers)
            
            Alamofire.request(URL_ACCOUNT_DETAILS , headers: headers).responseJSON()
                {
                    
                    response in
                    print("in alamo")
                    print(response)
                    switch response.result {
                    case .success(let value):
                        print("success",value)
                        print("hiiiii")
                        self.accountdetailsJSON = (response.result.value as? NSDictionary)!
                       if let accountDetailsArray = self.accountdetailsJSON["RetailerCustomerAccounts"] as? [NSDictionary] {
                        for obj in accountDetailsArray {
                            let retailer=obj["Retailer"] as? NSDictionary
                              self.retid = String(retailer?.value(forKey: "RetailerId") as! Int)
                            self.defaultValues.set(self.retid, forKey: "retid")
                              print("retailerid",self.retid)
                            self.getRecentPayments()
                            self.getSubscriptionDetails(monthLbl: self.lbl)
                        let  CurrentTotalDueAmount="\u{20B9}"+" "+String((obj["CurrentTotalDueAmount"] as? Float)!)
                        let  CurrentMonthBillAmount="\u{20B9}"+" "+String((obj["CurrentMonthBillAmount"] as? Float)!)
                        self.AccountDetailsArray.append(AccountDetails(totalDueAmount: CurrentTotalDueAmount, billAmount: CurrentMonthBillAmount))
                                print(CurrentTotalDueAmount)
                                print(CurrentMonthBillAmount)
                                print(self.AccountDetailsArray[0])
                       let UnBilledAmount = "\u{20B9}"+" "+String((obj["UnBilledAmount"] as? Float)!)
                       //let CurrentWalletAmount="\u{20B9}"+" "+String((obj["CurrentWalletAmount"] as? Float)!)
                            let CurrentWalletAmount="\u{20B9}"+" "+String((obj["BalanceAmount"] as? Float)!)
                            
                                print(UnBilledAmount)
                                print(CurrentWalletAmount)
                       self.AccountDetailsInfoArray.append(AccountDetailsInfo(unbilledAmount: UnBilledAmount, depositAmount: CurrentWalletAmount))
                                print(self.AccountDetailsInfoArray[0])
                           
                                self.firstTableView.reloadData()
                            }
                    
                        
                        }
                        
                                case .failure(let error):
                                print(error)
                    }
    
            }
        }
      
    }
    func getRecentPayments()
    {
 
        print("In getRecentPayments details")
      let urlconst = "https://nnj-dairyplus-pd-api.azurewebsites.net/api/"
        
        let URL_RECENT_PAYMENT_DETAILS = urlconst + "customer_payments/" + self.retid + "/08-2017"
        print("URL_RECENT_PAYMENT_DETAILS",URL_RECENT_PAYMENT_DETAILS)
        if let Authorization=defaultValues.string(forKey: "Authorization"){
            let headers: HTTPHeaders = [
                "Authorization": Authorization,
                "Content-Type": "application/json"
            ]
            print("header",headers)
            
            Alamofire.request(URL_RECENT_PAYMENT_DETAILS , headers: headers).responseJSON()
                {
                    
                    response in
                    print(response)
                    switch response.result {
                    case .success(let value):
                        print("success",value)
                        self.recentpaymentDetailsArray = (response.result.value as? [NSDictionary])!
                            for obj in self.recentpaymentDetailsArray
                            {
                      let PaymentAmont="\u{20B9}"+" "+String((obj["PaymentAmont"] as? Float)!)
                                let PaymentOn=(obj["PaymentOn"] as? String)!
                                var dateandtime: String=""
                                var myStringArr = PaymentOn.components(separatedBy: "T")
                                dateandtime.append(myStringArr[0])
                                let string1 = myStringArr[1]
                                let index = string1.index(string1.startIndex, offsetBy: 5)
                                let substring=string1.substring(to: index)
                                let dateAsString = substring
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "HH:mm"
                                let date = dateFormatter.date(from: dateAsString)
                                dateFormatter.dateFormat = "h:mm a"
                                let Date12 = dateFormatter.string(from: date!)
                                
                                dateandtime.append(" ")
                                dateandtime.append(Date12)
                               
                                let PaymentMethodCode=(obj["PaymentMethodCode"] as? String)!
                                var PaymentStatusCodeSymbol: NSMutableAttributedString!
                                let PaymentStatusCode=(obj["PaymentStatusCode"] as? String)!
                                let attachment = NSTextAttachment()
                            if(PaymentStatusCode == "Processed" || PaymentStatusCode == "Completed")
                            {
                                attachment.image = UIImage(named: "icons8-Ok-48")
                            }
                            else if(PaymentStatusCode == "Failed"){
                                attachment.image = UIImage(named : "icons8-High Importance-48")
                            }
                                else{
                                    attachment.image = UIImage(named: "icons8-Data Pending-64")
                                }
                                attachment.bounds = CGRect(x: 0, y: 0, width: 14, height: 14)
                                let attachmentStr = NSAttributedString(attachment: attachment)
                                let myString = NSMutableAttributedString(string: "")
                                myString.append(attachmentStr)
                                PaymentStatusCodeSymbol=myString
                                let refid=String(obj["Id"] as! Int)
                                self.recentpaymentDetailsInfoArray.append(RecentPayments(PaymentMethodCode: PaymentMethodCode, PaymentOn: dateandtime, PaymentAmont: PaymentAmont, PaymentStatusCode: PaymentStatusCodeSymbol,refid: refid,recPaymentStatusCode: PaymentStatusCode ))
                                
                        }
                        self.secondtableview.reloadData()
                        print("RC Count",self.recentpaymentDetailsInfoArray.count)

                    case .failure(let error):
                        print(error)
                    }
                    
            }
            
            }

        }
    func getSubscriptionDetails(monthLbl: String)
    {
      
        subscriptionsarray = [SubscriptionDet]()
        print("In getSubscriptionDetails ")
        let urlconst = "https://nnj-dairyplus-pd-api.azurewebsites.net/api/"
        if(self.retid != nil){
            print("in sub popup",self.retid)
 let URL_SUB_DET = urlconst + "customer_subscription/pull/" + self.retid + "?selectedDate=" + monthLbl
        //"31August2017"
        print("URL_SUBSCRIPTION_DETAILS",URL_SUB_DET)
        if let Authorization=defaultValues.string(forKey: "Authorization"){
            let headers: HTTPHeaders = [
                "Authorization": Authorization,
                "Content-Type": "application/json"
            ]
            print("header",headers)
            

            Alamofire.request(URL_SUB_DET,headers: headers).responseJSON()
                {
                    response in
                    print(response)
                    switch response.result {
                    case .success(let value):
                        print("success",value)
    self.subdetailsArray = (response.result.value as? [NSDictionary])!
                        for sub in self.subdetailsArray
                        {
                        let BrandName = (sub["BrandName"] as? String)!
                        let ProductName = (sub["ProductName"] as? String)!
                        let UnitPrice="\u{20B9}"+" "+String((sub["UnitPrice"] as? Float)!)
                        var Quantity: NSMutableAttributedString!
                        let attachment = NSTextAttachment()
                        attachment.image = UIImage(named: "icons8-Shopping Basket-64")
                        attachment.bounds = CGRect(x: 0, y: 0, width: 12, height: 14)
                        let attachmentStr = NSAttributedString(attachment: attachment)
                        let myString = NSMutableAttributedString(string: "")
                        myString.append(attachmentStr)
                        myString.append(NSMutableAttributedString(string: " "))
                        let Qty=(sub["Quantity"] as? Int)!
                        if(Qty > 1) {
                            let myString1 = NSMutableAttributedString(string: String(Qty))
                            myString1.append(NSMutableAttributedString(string:" "))
                            myString1.append(NSMutableAttributedString(string:"Packets"))
                            myString.append(myString1)
                            Quantity = myString
                            
                        }
                        else {
                            let myString1 = NSMutableAttributedString(string: String(Qty))
                            myString1.append(NSMutableAttributedString(string:" "))
                            myString1.append(NSMutableAttributedString(string:"Packet"))
                            myString.append(myString1)
                            Quantity = myString
                        }
                       let  imagethumbnail = (sub["ProductIconUrl"] as? String)!
            self.subscriptionsarray.append(SubscriptionDet(subimgthumbnail: imagethumbnail, subBrandName: BrandName, subProductName: ProductName, subUnitPrice: UnitPrice, subQuantity: Quantity))
            
                    }
                        self.thirdtableView.reloadData()
                        print("Sub Count",self.subscriptionsarray.count)
                        
                    case .failure(let error):
                        print(error)
                    

                }
            }
        }
    }
    }
  /*  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.firstTableView{
            return "Quick Bill"
        }
        else if tableView == self.secondtableview{
            return "Recent Payments"
        }
        else{
            return ""
        }
    }*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?=0
        
        if tableView == self.firstTableView {
           count = self.AccountDetailsArray.count + self.AccountDetailsInfoArray.count
        }
        
       if tableView == self.secondtableview {
        count = self.recentpaymentDetailsInfoArray.count
        if(count! > 0)
        {
        count = 3
        }
        }
        if tableView == self.thirdtableView {
            count = self.subscriptionsarray.count
        }
        print(count!)
        return count!
        
 
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         if tableView == self.firstTableView
         {
        
            self.firstTableView.layer.borderColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
            self.firstTableView.layer.borderWidth = 2.0
            self.firstTableView.layer.masksToBounds = false
            self.firstTableView.layer.cornerRadius = 2.0
            self.firstTableView.layer.shadowOffset = CGSize(width: -1, height: 1)
            self.firstTableView.layer.shadowOpacity = 0.2
         if indexPath.row == 0
         {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! TableViewCell1
        print("count",self.AccountDetailsArray.count)
        let accdet=self.AccountDetailsArray[indexPath.row]
        cell.totalDueAmount.text=accdet.totalDueAmount
        cell.billAmount.text = accdet.billAmount
        return cell
        }
         else
         {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell2") as! TableViewCell2
         let accdetinfo=self.AccountDetailsInfoArray[0]
         cell.depositAmount.text=accdetinfo.depositAmount
         cell.unbilledAmount.text=accdetinfo.unbilledAmount
         return cell
         }
            
        }
         else if tableView == self.secondtableview {
            print("in second table view",indexPath.row)
            self.secondtableview.layer.borderColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
            self.secondtableview.layer.borderWidth = 2.0
            self.secondtableview.layer.masksToBounds = false
            self.secondtableview.layer.cornerRadius = 2.0
            self.secondtableview.layer.shadowOffset = CGSize(width: -1, height: 1)
            self.secondtableview.layer.shadowOpacity = 0.2
            if(indexPath.row < 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3") as! TableViewCell3
            
            let recdetinfo=self.recentpaymentDetailsInfoArray[indexPath.row]
            print("In recent det array",recentpaymentDetailsInfoArray[0])
            cell.PaymentAmont.text=recdetinfo.PaymentAmont
            cell.PaymentMethodCode.text=recdetinfo.PaymentMethodCode
            cell.PaymentOn.text=recdetinfo.PaymentOn
           cell.PaymentStatusCode.attributedText=recdetinfo.PaymentStatusCode
            return cell
           }
          else{
               let cell = tableView.dequeueReusableCell(withIdentifier: "cell4") as! ViewMorebutton
                return cell
            }
        }
         else if tableView == self.thirdtableView {
            print("in thrd")
            self.thirdtableView.layer.borderColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
            self.thirdtableView.layer.borderWidth = 2.0
            self.thirdtableView.layer.masksToBounds = false
            self.thirdtableView.layer.cornerRadius = 2.0
            self.thirdtableView.layer.shadowOffset = CGSize(width: -1, height: 1)
            self.thirdtableView.layer.shadowOpacity = 0.2
            let cell = tableView.dequeueReusableCell(withIdentifier: "subcell") as! SubscriptionDetails
            let subdet = self.subscriptionsarray[indexPath.row]
            cell.BrandName.text=subdet.subBrandName
            cell.ProductName.text=subdet.subProductName
            cell.Quantity.attributedText=subdet.subQuantity
            cell.UnitPrice.text=subdet.subUnitPrice
            print(subdet.subimgthumbnail)
           let imageURL = URL(string: subdet.subimgthumbnail)
            
            let imagedData = try? Data(contentsOf: imageURL!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            
            cell.imageView?.image = UIImage(data: imagedData!)
            return cell

        }
            
        else
         {
            let cell = UITableViewCell()
            return cell
        }
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.firstTableView{
            if indexPath.row == 0 {
            return 150
        }
         else{
        return 70
            }
        }
          else  if tableView == self.secondtableview{
                if (indexPath.row < 2){
                    return 78
                }
                else{
                    return 70
                }
        }
        return 80
}
    
  /*  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "rec") {
            let navVC = segue.destination as! UINavigationController
            let tableVC = navVC.viewControllers.first as! RecentPaymentsViewController
            tableVC.recentpaymentDetailsInfoArray=self.recentpaymentDetailsInfoArray
        }
    
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
