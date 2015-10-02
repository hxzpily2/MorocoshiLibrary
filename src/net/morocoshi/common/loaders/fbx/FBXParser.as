package net.morocoshi.common.loaders.fbx 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	import net.morocoshi.common.loaders.fbx.events.FBXEvent;
	
	/**
	 * FBX2012(ASCII)のデータをパースする。
	 * 
	 * @author tencho
	 */
	public class FBXParser extends EventDispatcher
	{
		private var sprite:Sprite;
		private var completeNode:Function;
		private var completeScene:Function;
		private var parseNodeWeight:Number = 0.85;
		private var collector:FBXParseCollector;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function FBXParser() 
		{
			super();
			sprite = new Sprite();
		}
		
		//--------------------------------------------------------------------------
		//
		//  パース
		//
		//--------------------------------------------------------------------------
		
		/**
		 * FBXをパースしてFBXSceneオブジェクトにする
		 * @param	data
		 * @return
		 */
		public function parseScene(data:String, collector:FBXParseCollector):void
		{
			this.collector = collector;
			addEventListener(FBXEvent.COMPLETE_PARSE_NODE, parseNode_completeHanlder);
			parseNode(data);
		}
		
		private function parseNode_completeHanlder(e:FBXEvent):void 
		{
			removeEventListener(FBXEvent.COMPLETE_PARSE_NODE, parseNode_completeHanlder)
			
			var evt:FBXEvent = new FBXEvent(FBXEvent.COMPLETE_PARSE_SCENE);
			evt.node = e.node;
			var scene:FBXScene = new FBXScene();
			scene.parse(evt.node, collector);
			evt.scene = scene;
			dispatchEvent(evt);
		}
		
		public function notifyProgress(per:Number):void 
		{
			var e:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
			e.bytesLoaded = per;
			e.bytesTotal = 1;
			dispatchEvent(e);
		}
		
		/**
		 * FBXをパースしてFBXNodeオブジェクトにする
		 * @param	data
		 * @return
		 */
		public function parseNode(data:String):void
		{
			//文字列を字句解析してトークンの配列の生成を開始する
			
			notifyProgress(0);
			fbxString = data.split("\r\n").join("\n");
			tokenList = [];
			buffer = "";
			isString = false;
			isComment = false;
			index = -1;
			
			sprite.addEventListener(Event.ENTER_FRAME, parseToken_enterFrameHandler);
		}
		
		
		private var rootNode:FBXNode;
		private var currentNode:FBXNode;
		
		//トークンの配列の生成が完了した時
		private function completeParseToken():void 
		{
			sprite.removeEventListener(Event.ENTER_FRAME, parseToken_enterFrameHandler);
			
			rootNode = new FBXNode(null);
			currentNode = rootNode;
			
			//トークンから木構造を解析
			index = -1;
			sprite.addEventListener(Event.ENTER_FRAME, parseNode_enterFrameHandler);
		}
		
		private function completeParseNode():void 
		{
			sprite.removeEventListener(Event.ENTER_FRAME, parseNode_enterFrameHandler);
			
			notifyProgress(1);
			var e:FBXEvent = new FBXEvent(FBXEvent.COMPLETE_PARSE_NODE);
			e.node = rootNode;
			dispatchEvent(e);
		}
		
		private function parseNode_enterFrameHandler(e:Event):void
		{
			var t:int = getTimer();
			while(getTimer() - t < 100)
			{
				index++;
				if (index >= tokenList.length)
				{
					completeParseNode();
					return;
				}
				var token:String = tokenList[index];
				var nextNode:FBXNode = currentNode.addToken(token);
				if (nextNode) currentNode = nextNode;
			}
			notifyProgress(parseNodeWeight + (1 - parseNodeWeight) * index / tokenList.length);
		}
		
		/**
		 * FBXのルートFBXNodeを渡すとFBX文字列を生成する
		 * @param	node
		 * @return
		 */
		public function toFBXString(node:FBXNode):String
		{
			var str:String = "";
			str += "; FBX 7.2.0 project file\n";
			str += "; Copyright (C) 1997-2010 Autodesk Inc. and/or its licensors.\n";
			str += "; All rights reserved.\n";
			str += "; ----------------------------------------------------\n\n";
			str += node.toFBXString();
			return str;
		}
		
		private var fbxString:String;
		private var tokenList:Array;
		private var isString:Boolean;
		private var isComment:Boolean;
		private var qt:String;
		private var buffer:String;
		private var commentBuffer:String = "";
		private var index:int;
		
		private function parseToken_enterFrameHandler(e:Event):void 
		{
			var t:int = getTimer();
			while(getTimer() - t < 100)
			{
				index++;
				if (index >= fbxString.length)
				{
					completeParseToken();
					return;
				}
				
				var s:String = fbxString.charAt(index);
				var tag:Boolean = (s == "{" || s == "}" || s == "[" || s == "]");
				var rt:Boolean = (s == "\n");
				var eq:Boolean = (s == ":");
				var segment:Boolean = (s == ",");
				var comment:Boolean = (s == ";");
				var space:Boolean = (segment || eq || rt || tag || s == "\t" || s == " ");
				
				if (!isString)
				{
					//非文字列
					if (isComment)
					{
						commentBuffer += s;
						if (rt)
						{
							isComment = false;
							tokenList.push(commentBuffer);
							commentBuffer = "";
						}
						continue;
					}
					else
					{
						if (comment)
						{
							commentBuffer += ";"
							isComment = true;
							continue;
						}
					}
					if (space)
					{
						if (buffer != "") tokenList.push(buffer);
						if (rt) tokenList.push("\r");
						if (eq || tag || segment) tokenList.push(s);
						buffer = "";
						continue;
					}
					//文字列開始
					if (s == "'" || s == '"')
					{
						qt = s;
						isString = true;
					}
				}
				else
				{
					//文字列
					if (s == qt)
					{
						isString = false;
					}
				}
				if (isString || !space)
				{
					buffer += s;
				}
				if (index == fbxString.length - 1 && buffer != "")
				{
					tokenList.push(buffer);
				}
			}
			notifyProgress(parseNodeWeight * index / fbxString.length);
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
				
		static public function addPropertyNode(target:FBXNode, list:Array = null):void
		{
			var node:FBXNode = new FBXNode();
			for (var i:int = 0; i < list.length; i++) 
			{
				node.addValue("P", list[i]);
			}
			target.addValue("Properties70", [node]);
		}
		
		/**
		 * property70ノードをパースする
		 * @param	prop
		 * @return
		 */
		static public function parseProperties(prop:Array):Object
		{
			var param:Object = { };
			if (!prop || !prop.length) return param;
			for each(var item:Array in prop[0][0].P)
			{
				param[item[0]] = parseValue(item);
			}
			return param;
		}
		
		/**
		 * 文字列を適切なデータに変換する
		 * @param	d
		 * @return
		 */
		static private function parseValue(d:Array):* 
		{
			var key:String = d[1].toLowerCase();
			switch(key)
			{
				case "vector3d": case "lcl translation": case "lcl rotation": case "lcl scaling": return new Vector3D(d[4], d[5], d[6]);
				case "kstring": return String(d[4]);
				case "bool": return d[4] == 1;
				case "fieldofview": return d[4] * Math.PI / 180;
				case "ktime": case "enum": case "double": case "number": return d[4];
				case "int": return int(d[4]);
				case "colorrgb": case "color": return (d[4] * 0xFF << 16) | (d[5] * 0xFF << 8) | (d[6] * 0xFF);
			}
			return null;
		}
		
	}

}