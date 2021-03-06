package net.morocoshi.common.loaders.collada.nodes 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import mx.utils.StringUtil;
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.loaders.collada.ColladaUtil;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.common.text.XMLUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ColladaObjectNode extends ColladaNode
	{
		static public const TYPE_MESH:String = "mesh";
		static public const TYPE_LIGHT:String = "light";
		static public const TYPE_OBJECT:String = "object";
		static public const TYPE_JOINT:String = "joint";
		static public const TYPE_SKIN:String = "skin";
		static public const TYPE_SKIN_CONTAINER:String = "skinContainer";
		
		public var type:String;
		public var instanceLink:String;
		public var parent:ColladaObjectNode;
		
		public var userData:Object;
		public var visible:Boolean;
		public var castShadow:Boolean;
		public var receiveShadows:Boolean;
		public var matrix:Matrix3D;
		public var childlen:Vector.<ColladaObjectNode>;
		public var bindMaterial:Object;
		public var jointIndex:int;
		public var jointMatrix:Matrix3D;
		public var sid:String;
		
		public function ColladaObjectNode() 
		{
			type = TYPE_OBJECT;
			matrix = new Matrix3D();
			childlen = new Vector.<ColladaObjectNode>;
			visible = true;
			castShadow = true;
			receiveShadows = true;
			bindMaterial = { };
			userData = { };
		}
		
		override public function parse(xml:XML, collector:ColladaCollector):void
		{
			super.parse(xml, collector);
			collector.linkObjectAnimation(this);
			var i:int;
			var n:int;
			
			type = TYPE_OBJECT;
			visible = true;
			castShadow = true;
			receiveShadows = true;
			bindMaterial = { };
			childlen.length = 0;
			
			sid = XMLUtil.getAttrString(xml, "sid", "");
			
			var list:Array;
			
			var extraTechnique:XML = xml.extra.technique[0];
			if (extraTechnique)
			{
				visible = XMLUtil.getNodeNumber(extraTechnique.primary_visibility[0], 1) == 1;
				castShadow = XMLUtil.getNodeNumber(extraTechnique.cast_shadows[0], 1) == 1;
				receiveShadows = XMLUtil.getNodeNumber(extraTechnique.receive_shadows[0], 1) == 1;
			}
			
			if (xml.matrix[0])
			{
				matrix = ColladaUtil.toMatrix3D(xml.matrix[0]);
			}
			else
			{
				matrix = new Matrix3D();
				
				var transforms:Array = [];
				var transform:XML;
				for each(transform in xml.children())
				{
					if (transform.@sid == "post-rotationY") continue;
					transforms.push(transform);
				}
				transforms.reverse();
				n = transforms.length;
				for (i = 0; i < n; i++)
				{
					transform = transforms[i];
					
					var nodeName:String = transform.name();
					if (nodeName == "rotate")
					{
						list = ColladaUtil.toNumberArray(transform);
						matrix.appendRotation(list[3], new Vector3D(list[0], list[1], list[2]));
					}
					if (nodeName == "scale")
					{
						list = ColladaUtil.toNumberArray(transform);
						matrix.appendScale(list[0], list[1], list[2]);
					}
					if (nodeName == "translate")
					{
						list = ColladaUtil.toNumberArray(transform);
						matrix.appendTranslation(list[0], list[1], list[2]);
					}
				}
			}
			
			//単位スケーリング
			collector.fixMatrixScale(matrix);
			
			var controller:XML = xml.instance_controller[0];
			if (controller)
			{
				type = TYPE_SKIN;
				instanceLink = XMLUtil.getAttrString(controller, "url", "");
				for each(var link1:XML in controller..instance_material)
				{
					bindMaterial[link1.@symbol] = link1.@target;
				}
			}
			
			var geom:XML = xml.instance_geometry[0];
			if (geom)
			{
				type = TYPE_MESH;
				instanceLink = XMLUtil.getAttrString(geom, "url", "");
				for each(var link:XML in geom..instance_material)
				{
					bindMaterial[link.@symbol] = link.@target;
				}
			}
			
			if (XMLUtil.getAttrString(xml, "type", "") == "JOINT")
			{
				type = TYPE_JOINT;
				jointIndex = collector.jointIndexMap[sid];
				jointMatrix = collector.jointMatrixMap[sid];
			}
			
			var extra:XML = xml.extra[0];
			if (extra && extra..user_properties[0])
			{
				parseUserProp(String(extra..user_properties[0]));
			}
			
			if (xml.instance_light[0])
			{
				type = TYPE_LIGHT;
				instanceLink = XMLUtil.getAttrString(xml.instance_light[0], "url", "");
			}
			
			for each(var node:XML in xml.node)
			{
				var child:ColladaObjectNode = new ColladaObjectNode();
				child.parent = this;
				child.parse(node, collector);
				childlen.push(child);
			}
			
			var hasAnimation:Boolean = (collector.option.exportAnimation && animation != null);
			if (collector.option.mergeNestedMesh && childlen.length == 1 && childlen[0].existID == false && childlen[0].type == TYPE_MESH && hasAnimation == false)
			{
				mergeFrom(childlen[0]);
				childlen.length = 0;
			}
		}
		
		/**
		 * 本来入れ子ではないメッシュが空のObjectに包まれている場合があり、
		 * 元のメッシュに戻す為に子Meshを親Objectに統合させる処理
		 * アニメーションが設定されている場合は統合により姿勢が変化してしまうため実行しない事
		 * @param	node
		 */
		private function mergeFrom(node:ColladaObjectNode):void 
		{
			matrix.prepend(node.matrix);
			instanceLink = node.instanceLink;
			type = node.type;
			bindMaterial = node.bindMaterial;
			visible = node.visible;
			castShadow = node.castShadow;
			receiveShadows = node.receiveShadows;
		}
		
		private function parseUserProp(text:String):void 
		{
			var list:Array = text.split("\r\n").join("\n").split("\n");
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				var line:String = list[i];
				if (line.charAt(line.length - 1) == ";")
				{
					line = line.substr(0, line.length - 1);
				}
				var seg:Array = line.split("=");
				var attr:String = StringUtil.trim(seg.shift());
				var value:String = StringUtil.trim(seg.join("="));
				var s:String = value.charAt(0);
				var e:String = value.charAt(value.length - 1);
				if (value.length >= 2 && s == e && (s == "'" || s == '"'))
				{
					userData[attr] = value.substr(1, value.length - 2);
				}
				else if (value == "true" || value == "false")
				{
					userData[attr] = (value == "true");
				}
				else
				{
					userData[attr] = parseFloat(value);
				}
			}
			delete userData["LastPose"];
			delete userData["MapChannel:1"];
		}
		
		public function getWorldMatrix():Matrix3D
		{
			var result:Matrix3D = matrix.clone();
			var parentNode:ColladaObjectNode = parent;
			while (parentNode && parentNode.matrix)
			{
				result.append(parentNode.matrix);
				parentNode = parentNode.parent;
			}
			return result;
		}
		
		public function getRootJoint():ColladaObjectNode 
		{
			var result:ColladaObjectNode = (type == TYPE_JOINT)? this : null;
			var parentNode:ColladaObjectNode = parent;
			while (parentNode)
			{
				if (parentNode.type == TYPE_JOINT)
				{
					result = parentNode;
				}
				parentNode = parentNode.parent;
			}
			return result;
		}
		
		public function addChildFixedly(node:ColladaObjectNode):void
		{
			var nodeMatrix:Matrix3D = node.getWorldMatrix();
			var thisMatrix:Matrix3D = getWorldMatrix();
			thisMatrix.invert();
			nodeMatrix.append(thisMatrix);
			node.matrix = nodeMatrix;
			
			addChild(node);
		}
		
		public function addChild(node:ColladaObjectNode):void 
		{
			if (node.parent)
			{
				VectorUtil.deleteItem(node.parent.childlen, node);
			}
			node.parent = this;
			childlen.push(node);
		}
		
	}

}