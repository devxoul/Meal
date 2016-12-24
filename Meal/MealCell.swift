//
//  MealCell.swift
//  Meal
//
//  Created by 전수열 on 1/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

class MealCell: UITableViewCell {

  enum MealType {
    case lunch
    case dinner
  }

  let titleLabel = UILabel()
  let contentLabel = UILabel()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none

    self.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
    self.contentLabel.font = UIFont.systemFont(ofSize: 15)
    self.contentLabel.numberOfLines = 0

    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.contentLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  class func cellHeightThatFitsWidth(_ width: CGFloat, forMeal meal: Meal, mealType: MealType) -> CGFloat {
    let text: String

    if mealType == .lunch {
      text = meal.lunch.joined(separator: ", ")
    } else {
      text = meal.dinner.joined(separator: ", ")
    }

    let titleLabelWidth: CGFloat = 50
    let contentLabelMaxWidth = width - titleLabelWidth - 10

    let size = CGSize(width: contentLabelMaxWidth, height: .greatestFiniteMagnitude)
    let rect = text.boundingRect(
      with: size,
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)],
      context: nil
    )
    return ceil(rect.height) + 20
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.titleLabel.sizeToFit()
    self.titleLabel.frame.origin.x = 10
    self.titleLabel.frame.origin.y = 10
    self.titleLabel.frame.size.width = 50

    self.contentLabel.frame.origin.x = 50
    self.contentLabel.frame.origin.y = 10
    self.contentLabel.frame.size.width = self.contentView.frame.width - self.contentLabel.frame.origin.x - 10
    self.contentLabel.sizeToFit()
  }

}
