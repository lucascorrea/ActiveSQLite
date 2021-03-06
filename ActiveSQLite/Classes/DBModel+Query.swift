//
//  DBModel+Query.swift
//  ActiveSQLite
//
//  Created by zhou kai on 08/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

//TODO select；group by；join

public extension DBModel{
    
    
    //MARK: - Find
    //MARK: - FindFirst
    class func findFirst(_ attribute: String, value:Any?)->DBModel?{
        return findAll(attribute, value: value)?.first
    }
    
    class func findFirst(_ attributeAndValueDic:Dictionary<String,Any?>)->DBModel?{
        return findAll(attributeAndValueDic)?.first
    }
    
    class func findFirst(orderColumn:String,ascending:Bool = true)->DBModel?{
        return findAll(orderColumn:orderColumn, ascending: ascending).first
    }
    
    class func findFirst(orders:[String:Bool]? = nil)->DBModel?{
        return findAll(orders:orders).first
    }
    
    class func findFirst(_ attribute: String, value:Any?,_ orderBy:String,ascending:Bool = true)->DBModel?{
        return findAll([attribute:value], [orderBy:ascending]).first
    }
    
    class func findFirst(_ attributeAndValueDic:Dictionary<String,Any?>?,_ orders:[String:Bool]? = nil)->DBModel?{
        return findAll(attributeAndValueDic, orders).first
    }
    
    class func findFirst(_ predicate: SQLite.Expression<Bool>,orders:[String:Bool])->DBModel?
    {
        return findAll(predicate,orders:orders)?.first
    }
    
    class func findFirst(_ predicate: SQLite.Expression<Bool?>,orders:[String:Bool])->DBModel?{
        return findAll(predicate,orders:orders)?.first
    }
    
    class func findFirst(_ predicate: SQLite.Expression<Bool>,orders: [Expressible]? = nil)->DBModel?
    {
        return findAll(predicate,orders:orders)?.first
    }
    
    class func findFirst(_ predicate: SQLite.Expression<Bool?>,orders: [Expressible]? = nil)->DBModel?{
        return findAll(predicate,orders:orders)?.first
    }
    
    
    //MARK: FindAll
    class func findAll(_ attribute: String, value:Any?)->Array<DBModel>?{
        return findAll([attribute:value])
    }
    
    class func findAll(_ attributeAndValueDic:Dictionary<String,Any?>)->Array<DBModel>?{
        return findAll(attributeAndValueDic, nil)
    }
    
    
    class func findAll(orderColumn:String,ascending:Bool = true)->Array<DBModel>{
        return findAll(nil, [orderColumn:ascending])
    }
    
    class func findAll(orders:[String:Bool]? = nil)->Array<DBModel>{
        return findAll(nil, orders)
        
    }
    
    class func findAll(_ attributeAndValueDic:Dictionary<String,Any?>,orders:[String:Bool])->Array<DBModel>{
        return findAll(attributeAndValueDic, orders: orders)
    }
    
    class func findAll(_ attributeAndValueDic:Dictionary<String,Any?>?,_ orders:[String:Bool]? = nil)->Array<DBModel>{
        
        
        var results:Array<DBModel> = Array<DBModel>()
        var query = getTable()
        
        if attributeAndValueDic != nil {
            if let expression = self.init().buildExpression(attributeAndValueDic!) {
                query = query.where(expression)
            }
        }
        
        if orders != nil {
            query = query.order(self.init().buildExpressiblesForOrder(orders!))
        }
        
        do{
            for row in try db.prepare(query) {
                let model = self.init()
                model.buildFromRow(row: row)
                results.append(model)
            }
        }catch{
            LogError(error)
        }
        
        
        return results
    }
    
    class func findAll(_ predicate: SQLite.Expression<Bool>,orders:[String:Bool])->Array<DBModel>?{
        
        return findAll(Expression<Bool?>(predicate),orders:self.init().buildExpressiblesForOrder(orders))
        
    }
    
    class func findAll(_ predicate: SQLite.Expression<Bool?>,orders:[String:Bool])->Array<DBModel>?{
        
        return findAll(predicate,orders:self.init().buildExpressiblesForOrder(orders))
        
    }
    
    class func findAll(_ predicate: SQLite.Expression<Bool>,order: Expressible)->Array<DBModel>?{
        
        return findAll(Expression<Bool?>(predicate),orders:[order])
    }
    
    class func findAll(_ predicate: SQLite.Expression<Bool>,orders: [Expressible])->Array<DBModel>?{
        
        return findAll(Expression<Bool?>(predicate),orders:orders)
    }
    
    
    class func findAll(_ predicate: SQLite.Expression<Bool>,orders: [Expressible]? = nil)->Array<DBModel>?{
        
        return findAll(Expression<Bool?>(predicate),orders:orders)
    }
    
    
    class func findAll(_ predicate: SQLite.Expression<Bool?>,orders: [Expressible]? = nil)->Array<DBModel>?{
        
        var results:Array<DBModel> = Array<DBModel>()
        var query = getTable().where(predicate)
        
        if orders != nil && orders!.count > 0 {
            query = query.order(orders!)
        }else{
            if isSaveDefaulttimestamp {
                query = query.order(created_at.desc)
            }
        }
        
        
        do{
            for row in try db.prepare(query) {
                
                let model = self.init()
                
                model.buildFromRow(row: row)
                
                
                results.append(model)
            }
        }catch{
            LogError("Find all for \(nameOfTable) failure: \(error)")
        }
        
        
        return results
    }
    
    
    //MARK: - Generic Type
    func findAll<T:DBModel>(_ predicate: SQLite.Expression<Bool>, toT t:T)->Array<T>?{
        
        return findAll(Expression<Bool?>(predicate),toT:t)
    }
    
    func findAll<T:DBModel>(_ predicate: SQLite.Expression<Bool?>, toT t:T)->Array<T>?{
        
        var results:[T] = [T]()
        
        var query = getTable().where(predicate)
        if type(of: self).isSaveDefaulttimestamp{
            query = query.order(type(of: self).created_at.desc)
        }
        
        
        do{
            for result in try T.db.prepare(query) {
                
                let model = T()
                model.buildFromRow(row: result)
                
                results.append(model)
            }
        }catch{
            LogError("Find all for \(nameOfTable) failure: \(error)")
        }
        
        
        return results
    }
    
    func findAll<T:DBModel>(_ predicate: SQLite.Expression<Bool?>)->Array<T>?{
        
        var results:[T] = [T]()
        
        var query = getTable().where(predicate)
        
        if type(of: self).isSaveDefaulttimestamp {
            query = query.order(type(of: self).created_at.desc)
        }
        
        
        do{
            for result in try T.db.prepare(query) {
                
                let model = T()
                model.buildFromRow(row: result)
                
                results.append(model)
            }
        }catch{
            LogError("Find all for \(nameOfTable) failure: \(error)")
        }
        
        
        return results
    }
    
    internal func findAll<T:DBModel>(_ predicate: SQLite.Expression<Bool?>) -> [T] where T : ASModel{
        
        var results:[T] = [T]()
        
        var query = getTable().where(predicate)
        
        if type(of: self).isSaveDefaulttimestamp {
            query = query.order(type(of: self).created_at.desc)
        }
        
        do{
            for result in try T.db.prepare(query) {
                
                let model = T()
                model.buildFromRow(row: result)
                
                results.append(model)
            }
        }catch{
            LogError("Find all for \(nameOfTable) failure: \(error)")
        }
        
        
        return results
    }
    
    //MARK: - Query
    
    var query:QueryType?{
        set{
            _query = newValue
        }
        get{
            if _query == nil {
                _query =  getTable()
            }
            return _query
        }
    }
    
    
    public func join(_ table: QueryType, on condition: Expression<Bool>) -> Self {
        query = query?.join(table, on: condition)
        return self
    }
    
    public func join(_ table: QueryType, on condition: Expression<Bool?>) -> Self {
        query = query?.join(table, on: condition)
        return self
    }
    
    public func join(_ type: JoinType, _ table: QueryType, on condition: Expression<Bool>) -> Self {
        query = query?.join(type, table, on: condition)
        return self
    }
    
    
    public func join(_ type: JoinType, _ table: QueryType, on condition: Expression<Bool?>) -> Self {
        query = query?.join(type, table, on: condition)
        return self
    }
    
    
    public func `where`(_ attribute: String, value:Any?)->Self{
        
        if let expression = buildExpression(attribute, value: value) {
            return self.where(expression)
        }
        return self
    }
    
    public func `where`(_ attributeAndValueDic:Dictionary<String,Any?>)->Self{
        
        if let expression = buildExpression(attributeAndValueDic) {
            return self.where(expression)
        }
        return self
    }
    
    public func `where`(_ predicate: SQLite.Expression<Bool>)->Self{
        query = query?.where(predicate)
        return self
    }
    
    public func `where`(_ predicate: SQLite.Expression<Bool?>)->Self{
        query = query?.where(predicate)
        return self
    }
    
    public func group(_ by: Expressible...) -> Self {
        query = query?.group(by)
        return self
    }
    
    public func group(_ by: [Expressible]) -> Self {
        query = query?.group(by)
        return self
    }
    
    public func group(_ by: Expressible, having: Expression<Bool>) -> Self {
        query = query?.group(by, having: having)
        return self
    }
    public func group(_ by: Expressible, having: Expression<Bool?>) -> Self {
        query = query?.group(by, having: having)
        return self
    }
    
    public func group(_ by: [Expressible], having: Expression<Bool>) -> Self {
        query = query?.group(by, having: having)
        return self
    }
    
    public func group(_ by: [Expressible], having: Expression<Bool?>) -> Self {
        query = query?.group(by, having: having)
        return self
    }
    
    public func orderBy(_ sorted:String, asc:Bool = true)->Self{
        query = query?.order(buildExpressiblesForOrder([sorted:asc]))
        return self
    }
    
    public func orderBy(_ sorted:[String:Bool])->Self{
        query = query?.order(buildExpressiblesForOrder(sorted))
        return self
    }
    
    public func order(_ by: Expressible...) -> Self {
        query = query?.order(by)
        return self
    }
    
    public func order(_ by: [Expressible]) -> Self {
        query = query?.order(by)
        return self
    }
    
    public func limit(_ length: Int?) -> Self {
        query = query?.limit(length)
        return self
    }
    
    public func limit(_ length: Int, offset: Int) -> Self {
        query = query?.limit(length, offset: offset)
        return self
    }
    
    
    func run()->Array<DBModel>{
        
        var results:Array<DBModel> = Array<DBModel>()
        do{
            for row in try type(of: self).db.prepare(query!) {
                
                let model = type(of: self).init()
                
                model.buildFromRow(row: row)
                
                
                results.append(model)
            }
        }catch{
            LogError("Execute run() from \(nameOfTable) failure。\(error)")
        }
        
        
        query = nil
        
        LogInfo("Execute Query run() function from \(nameOfTable)  success")
        
        return results
        
    }
    
    //MARK: - Delete
    func runDelete()throws{
        do {
            if try type(of: self).db.run(query!.delete()) > 0 {
                LogInfo("Delete rows of \(nameOfTable) success")
                
            } else {
                LogWarn("Delete rows of \(nameOfTable) failure。")
                
            }
        } catch {
            LogError("Delete rows of \(nameOfTable) failure。")
            throw error
        }
    }
    
    func delete() throws{
        guard id != nil else {
            return
        }
        
        let query = getTable().where(type(of: self).id == id)
        do {
            if try db.run(query.delete()) > 0 {
                LogInfo("Delete  \(nameOfTable)，id:\(id)  success")
                
            } else {
                LogWarn("Delete \(nameOfTable) failure，haven't found id:\(id) 。")
                
            }
        } catch {
            LogError("Delete failure: \(error)")
            throw error
        }
    }
    
    class func deleteBatch(_ models:[DBModel]) throws{
        
        do{
            
            try db!.savepoint("savepointname_\(nameOfTable)_deleteBatch\(NSDate().timeIntervalSince1970 * 1000)", block: {
                
                var ids = Array<NSNumber>()
                for model in models{
                    if model.id == nil {
                        continue
                    }
                    ids.append(model.id)
                }
                
                let query = getTable().where(ids.contains(id))
                
                try db!.run(query.delete())
                
                LogInfo("Delete batch rows of \(nameOfTable) success")
            })
        }catch{
            LogError("Delete batch rows of \(nameOfTable) failure: \(error)")
            throw error
        }
    }
    
    class func deleteAll() throws{
        do{
            try db.run(getTable().delete())
            LogInfo("Delete all rows of \(nameOfTable) success")
            
        }catch{
            LogError("Delete all rows of \(nameOfTable) failure: \(error)")
            throw error
        }
    }
    
    //MARK: - Comment
    internal func buildExpression(_ attribute: String, value:Any?)->SQLite.Expression<Bool?>?{
        
        return buildExpression([attribute:value])
        
    }
    
    internal func buildExpression(_ attributeAndValueDic:Dictionary<String,Any?>)->SQLite.Expression<Bool?>?{
        
        
        var expressions = Array<SQLite.Expression<Bool?>>()
        
        for case let (attribute?,column?, v) in recursionProperties() {
            
            if attributeAndValueDic.keys.contains(attribute) {
                
                let value = attributeAndValueDic[attribute]
                let mir = Mirror(reflecting:v)
                
                switch mir.subjectType {
                    
                case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type:
                    expressions.append(Expression<Bool?>(Expression<String>(column) == value as! String))
                case _ as String?.Type:
                    expressions.append(Expression<String?>(column) == value as! String?)
                    
                case _ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                    
                    if self.doubleTypes().contains(attribute) {
                        expressions.append(Expression<Bool?>(Expression<Double>(column) == value as! Double))
                    }else{
                        expressions.append(Expression<Bool?>(Expression<NSNumber>(column) == value as! NSNumber))
                    }
                    
                case _ as NSNumber?.Type:
                    
                    if self.doubleTypes().contains(attribute) {
                        expressions.append(Expression<Double?>(column) == value as? Double)
                        
                    }else{
                        expressions.append(Expression<NSNumber?>(column) == value as? NSNumber)
                        
                    }
                    
                case _ as NSDate.Type, _ as  ImplicitlyUnwrappedOptional<NSDate>.Type:
                    expressions.append(Expression<Bool?>(Expression<NSDate>(column) == value as! NSDate))
                case _ as NSDate?.Type:
                    expressions.append(Expression<NSDate?>(column) == value as! NSDate?)
                    
                default: break
                    
                }
                
            }
            
        }
        
        if expressions.count > 1 {
            var exp = expressions.first!
            for i in 1..<expressions.count {
                exp = exp && expressions[i]
            }
            return exp
        }else{
            return expressions.first
        }
        
    }
    
    internal func buildExpressiblesForOrder(_ attributeAndAscDic:Dictionary<String,Bool>)->[Expressible]{
        
        
        var expressibles = [Expressible]()
        
        for case let (attribute?,column?, v) in recursionProperties() {
            
            if attributeAndAscDic.keys.contains(attribute) {
                
                let isAsc = attributeAndAscDic[attribute]!
                let mir = Mirror(reflecting:v)
                
                switch mir.subjectType {
                    
                case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type:
                    expressibles.append((isAsc ? Expression<String>(column).asc : Expression<String>(column).desc))
                case _ as String?.Type:
                    expressibles.append((isAsc ? Expression<String?>(column).asc : Expression<String?>(column).desc))
                    
                case _ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                    
                    if self.doubleTypes().contains(attribute) {
                        expressibles.append((isAsc ? Expression<Double>(column).asc : Expression<Double>(column).desc))
                    }else{
                        expressibles.append((isAsc ? Expression<NSNumber>(column).asc : Expression<NSNumber>(column).desc))
                    }
                    
                case _ as NSNumber?.Type:
                    
                    if self.doubleTypes().contains(attribute) {
                        expressibles.append((isAsc ? Expression<Double?>(column).asc : Expression<Double?>(column).desc))
                        
                    }else{
                        expressibles.append((isAsc ? Expression<NSNumber?>(column).asc : Expression<NSNumber?>(column).desc))
                        
                    }
                    
                case _ as NSDate.Type, _ as  ImplicitlyUnwrappedOptional<NSDate>.Type:
                    expressibles.append((isAsc ? Expression<NSDate>(column).asc : Expression<NSDate>(column).desc))
                case _ as NSDate?.Type:
                    expressibles.append((isAsc ? Expression<NSDate?>(column).asc : Expression<NSDate?>(column).desc))
                    
                default: break
                    
                }
                
            }
            
        }
        return expressibles
        
    }
    
    //MARK: - Build
    internal func buildFromRow(row:Row){
        
        for case let (attribute?,column?, value) in recursionProperties() {
            //            let s = "Attribute ：\(attribute) Value：\(value),   " +
            //                    "Mirror: \(Mirror(reflecting:value)),  " +
            //                    "Mirror.subjectType: \(Mirror(reflecting:value).subjectType),    " +
            //                    "Mirror.displayStyle: \(String(describing: Mirror(reflecting:value).displayStyle))"
            //            LogDebug(s)
            //            LogDebug("assign Value-\(value) to \(attribute)-attribute of \(nameOfTable). ")
            
            
            let mir = Mirror(reflecting:value)
            
            switch mir.subjectType {
                
            case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type:
                setValue(row[Expression<String>(column)], forKey: attribute)
                
            case _ as String?.Type:
                if let v = row[Expression<String?>(column)] {
                    setValue(v, forKey: attribute)
                }else{
                    setValue(nil, forKey: attribute)
                }
                
                
            case _ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                
                if self.doubleTypes().contains(attribute) {
                    setValue(NSNumber(value:try! row.get(Expression<Double>(column))) , forKey: attribute)
                }else{

                    let v = try! row.get(Expression<NSNumber>(column))
                    setValue(v, forKey: attribute)

                }
                
            case _ as NSNumber?.Type:
                
                if self.doubleTypes().contains(attribute) {
                    if let v = try! row.get(Expression<Double?>(column)) {
                        setValue(NSNumber(value:v), forKey: attribute)
                    }
                }else{
                    if let v = try! row.get(Expression<NSNumber?>(column)) {
                        setValue(v, forKey: attribute)
                    }else{
                        setValue(nil, forKey: attribute)
                    }
                }
                
            case _ as NSDate.Type, _ as  ImplicitlyUnwrappedOptional<NSDate>.Type:
                setValue(try! row.get(Expression<NSDate>(column)), forKey: attribute)
                
            case _ as NSDate?.Type:
                if let v = try! row.get(Expression<NSDate?>(column)) {
                    setValue(v, forKey: attribute)
                }else{
                    setValue(nil, forKey: attribute)
                }
                
            default: break
                
            }
            
        }
    }
    
    
}
