package net.morocoshi.common.loaders.fbx 
{
	/**
	 * FBXデータを構成する基本データ。
	 * 基本的にObjectと同じようにキーでアクセスします。
	 * FBXの構成上、キーは重複している可能性があるため
	 * 全てのキーに対応するデータはArray型のデータになっており、
	 * さらに各データはFBX文字列からは配列なのか単独の値なのか区別がつかない為、
	 * 単独の値であっても要素数1のArrayデータになっています。
	 * 
	 * このオブジェクトがAというキーを1つ持ち、その中にBというデータが1つある場合でも
	 * Bにアクセスする時はFBXNode.A[0][0];という記述になります。
	 * 
	 * @author tencho
	 */
	public dynamic class FBXNode 
	{
		//親FBXNode
		private var $parent:FBXNode;
		private var $key:String;
		//オブジェクトデータ初期化時に渡す配列パラメータ
		public var $args:Array;
		//配列の値を一時的に補完しておくところ
		private var $stock:Array;
		private var $eqMode:Boolean = false;
		private var $inArray:Boolean = false;
		private var $commentList:Array;
		private var $comment:Object = { };
		
		public function FBXNode(parent:FBXNode = null, args:Array = null) 
		{
			$parent = parent;
			if(args) $args = args.concat();
		}
		
		public function addToken(token:String):FBXNode
		{
			var d:* = token;
			
			if (token == ",")
			{
				$inArray = true;
				return null;
			}
			
			if (token == ":")
			{
				$eqMode = true;
				return null;
			}
			
			if (token == "{")
			{
				//FBXNodeオブジェクト化
				d = new FBXNode(this, $stock);
				$stock = null;
			}
			
			if (token == "}")
			{
				//親のFBXNodeに戻る
				return $parent;
			}
			
			if (token.charAt(0) == ";")
			{
				if ($commentList == null)
				{
					$commentList = [];
				}
				$commentList.push(token.substr(1));
				return null;
			}
			
			//改行
			if (token == "\r")
			{
				//配列の途中の改行は無視する
				if ($inArray) return null;
				//$stockに入れておいた配列を$keyに追加
				if ($key)
				{
					var data:* = $stock? $stock.concat() : null;
					if (this[$key])
					{
						this[$key].push(data);
						$comment[$key].push($commentList);
					}
					else
					{
						this[$key] = [data];
						$comment[$key] = [$commentList];
					}
				}
				//一時変数をリセット
				$commentList = null;
				$key = null;
				$stock = null;
				$eqMode = false;
				return null;
			}
			
			if ($eqMode)
			{
				//データセット
				var v:* = (d is FBXNode)? d : toValue(d);
				if ($stock)
				{
					$stock.push(v);
				}
				else
				{
					$stock = [v];
				}
				$inArray = false;
			}
			else
			{
				//データキー
				$key = d;
			}
			
			return d as FBXNode;
		}
		
		/**
		 * 文字列を適切な値にする
		 * @param	str
		 * @return
		 */
		private function toValue(str:String):*
		{
			var n:int = str.length;
			var s:String = str.charAt(0);
			var e:String = str.charAt(str.length -1);
			if ((s == '"' && e == '"') || (s == "'" && e == "'"))
			{
				return str.substr(1, n -2);
			}
			if (s == "*")
			{
				return new FBXNumber(Number(str.substr(1)));
			}
			return Number(str);
		}
		
		public function getComment(key:String, index:int):Array
		{
			return $comment[key][index];
		}
		
		public function toString():String
		{
			return "[FBXNode::(" + $args + ")]";
		}
		
		public function toFBXString():String
		{
			FBXPriority.init();
			return getFBXCode(0, "Root");
		}
		
		public function addListValue(name:String, list:Array):void
		{
			var fbx:FBXNode = new FBXNode(null, [new FBXNumber(list.length)]);
			fbx.addValue("a", list);
			addValue(name, [fbx]);
		}
		
		public function addValue(name:String, list:Array):void 
		{
			if (!this[name])
			{
				this[name] = [list];
			}
			else
			{
				this[name].push(list);
			}
		}
		
		private function getFBXCode(depth:int, parent:String):String
		{
			var i:int;
			var arg:String = $args? getListString($args, depth, parent) : "";
			var str:String = "";
			var tab1:String = "";
			var tab2:String = "";
			for (i = 0; i < depth; i++) tab1 += "\t";
			for (i = 0; i < depth - 1; i++) tab2 += "\t";
			if (depth) str += arg + " {\n";
			var dataList:Array = [];
			for (var k:String in this)
			{
				var data:String = "";
				var n:int = this[k].length;
				for (i = 0; i < n; i++) 
				{
					data += tab1 + k + ": " + getListString(this[k][i], depth + 1, k) + "\n";
				}
				dataList.push( { data:data, priority:FBXPriority.getPriority(parent, k) } );
			}
			dataList.sortOn("priority", Array.NUMERIC);
			n = dataList.length;
			for (i = 0; i < n; i++) 
			{
				str += dataList[i].data;
			}
			if (depth) str += tab2 + "}";
			return str;
		}
		
		private function getListString(list:Array, depth:int, parent:String):String
		{
			var values:Array = [];
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				values.push(toValueString(list[i], depth, parent));
			}
			return values.join(",");
		}
		
		private function toValueString(value:*, depth:int, parent:String):String
		{
			if (value is FBXNode)
			{
				value = FBXNode(value).getFBXCode(depth, parent);
			}
			else if (value is String)
			{
				value = '"' + value + '"';
			}
			else if (value is FBXNumber)
			{
				value = FBXNumber(value).toString();
			}
			else
			{
				value = Number(value).toString(10);
			}
			return value;
		}
		
	}

}