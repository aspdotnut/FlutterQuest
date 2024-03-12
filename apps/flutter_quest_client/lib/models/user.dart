// FlutterQuest
// A simple chatroom with certain game elements.
// Copyright (C) 2024 aspdotnut
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:equatable/equatable.dart';

class User extends Equatable {

  final int id;
  final String name;
  final int x;
  final int y;
  final bool legMovement;
  final bool isActive;

  const User({

    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.legMovement,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, x, y, legMovement, isActive];
}