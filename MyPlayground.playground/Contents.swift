import Foundation

enum DirectionError: Error {
    case directionError(String)
}

enum Direction {
    case longitude, latitude
}

class CoordinateYF {
    var direction: Direction;
    var degrees: NSInteger;
    var minutes: NSInteger;
    var seconds: NSInteger;
    
    init(dir: Direction = .longitude, deg: NSInteger = 0, min: NSInteger = 0, sec: NSInteger = 0) throws {
        if dir == .longitude && (-180...180).contains(deg) && (0...59).contains(min) && (0...59).contains(sec) {
            self.direction = dir;
            self.degrees = deg;
            self.minutes = min;
            self.seconds = sec;
        }
        else if dir == .latitude && (-90...90).contains(deg) && (0...59).contains(min) && (0...59).contains(sec) {
            self.direction = dir;
            self.degrees = deg;
            self.minutes = min;
            self.seconds = sec;
        } else {
            throw DirectionError.directionError("Invalid direction format")
        }
    }
    
    func way() -> String {
        if self.direction == .longitude {
            return self.degrees > 0 ? "E" : "W";
        } else {
            return self.degrees > 0 ? "N" : "S";
        }
    }
    
    func toString() -> String {
        return "\(self.degrees)°\(self.minutes)'\(self.seconds)\" \(way())";
    }
    
    func toDecimalString() -> String {
        return "\(Double(self.degrees) + Double(self.minutes) / 60.0 + Double(self.seconds) / 3600.0)° \(way())";
    }
    
    func halfWay(to: CoordinateYF) throws -> CoordinateYF? {
        if (self.direction == to.direction) {
            return try CoordinateYF(dir: self.direction, deg: (self.degrees + to.degrees) / 2, min: (self.minutes + to.minutes) / 2, sec: (self.seconds + to.seconds) / 2)
        }
        return nil;
    }
    
    static func halfWay(from: CoordinateYF, to: CoordinateYF) throws -> CoordinateYF? {
        if (from.direction == to.direction) {
            return try CoordinateYF(dir: from.direction, deg: (from.degrees + to.degrees) / 2, min: (from.minutes + to.minutes) / 2, sec: (from.seconds + to.seconds) / 2)
        }
        return nil;
    }
}

do {
    let dir = try CoordinateYF(dir: .longitude, deg: 90, min: 23, sec: 35);
    let dir1 = try CoordinateYF(dir: .longitude, deg: 40, min: 0, sec: 0);
    let dir2 = try CoordinateYF(dir: .latitude, deg: 40, min: 0, sec: 0);
    print(dir.toString());
    print(dir.toDecimalString());
    print(try dir.halfWay(to: dir1)!.toString());
    print(try dir.halfWay(to: dir2) as Any);
    try CoordinateYF(dir: .latitude, deg: -181, min: 0, sec: 0);
} catch DirectionError.directionError(let err) {
    print(err);
}
