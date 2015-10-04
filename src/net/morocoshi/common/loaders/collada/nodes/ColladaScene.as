package net.morocoshi.common.loaders.collada.nodes 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	
	/**
	 * 全オブジェクト情報
	 * 
	 * @author tencho
	 */
	public class ColladaScene
	{
		public var asset:ColladaAssetNode;
		public var root:ColladaObjectNode;
		public var lights:Vector.<ColladaLightNode>;
		public var effects:Vector.<ColladaEffectNode>;
		public var geometries:Vector.<ColladaGeometryNode>;
		public var images:Vector.<ColladaImageNode>;
		public var materials:Vector.<ColladaMaterialNode>;
		public var controllers:Vector.<ColladaControllerNode>;
		public var animations:Vector.<ColladaAnimationNode>;
		
		public function ColladaScene() 
		{
			asset = new ColladaAssetNode();
			root = new ColladaObjectNode();
			lights = new Vector.<ColladaLightNode>;
			effects = new Vector.<ColladaEffectNode>;
			geometries = new Vector.<ColladaGeometryNode>;
			images = new Vector.<ColladaImageNode>;
			materials = new Vector.<ColladaMaterialNode>;
			controllers = new Vector.<ColladaControllerNode>;
			animations = new Vector.<ColladaAnimationNode>;
		}
		
		public function parse(xml:XML, collector:ColladaCollector):void
		{
			if (xml.asset[0])
			{
				asset.parse(xml.asset[0], collector);
			}
			
			var node:XML;
			
			if (xml.library_controllers[0])
			{
				for each(node in xml.library_controllers[0].controller)
				{
					var controller:ColladaControllerNode = new ColladaControllerNode();
					controller.parse(node, collector);
					controllers.push(controller);
				}
			}
			
			if (xml.library_animations[0] && collector.option.exportAnimation)
			{
				
				for each(node in xml.library_animations[0].animation)
				{
					var animation:ColladaAnimationNode = new ColladaAnimationNode();
					animation.parse(node, collector);
					animations.push(animation);
					
					collector.collectAnimation(animation);
				}
				//___collector.animation.parse(xml.library_animations[0].animation[0], collector);
			}
			
			if (xml.library_visual_scenes[0])
			{
				for each(node in xml.library_visual_scenes[0].visual_scene[0].node)
				{
					var object:ColladaObjectNode = new ColladaObjectNode();
					object.parse(node, collector);
					if (object.type == ColladaObjectNode.TYPE_SKIN)
					{
						object.matrix = getControllerByID(object.instanceLink).shapeMatrix;
					}
					root.addChild(object);
				}
			}
			
			if (xml.library_images[0])
			{
				for each(node in xml.library_images[0].image)
				{
					var image:ColladaImageNode = new ColladaImageNode();
					image.parse(node, collector);
					images.push(image);
				}
			}
			
			if (xml.library_lights[0])
			{
				for each(node in xml.library_lights[0].light)
				{
					var light:ColladaLightNode = new ColladaLightNode();
					light.parse(node, collector);
					lights.push(light);
				}
			}
			
			if (xml.library_geometries[0])
			{
				for each(node in xml.library_geometries[0].geometry)
				{
					var geometry:ColladaGeometryNode = new ColladaGeometryNode();
					geometry.parse(node, collector);
					geometries.push(geometry);
					
					for each(var cc:ColladaControllerNode in controllers)
					{
						if (geometry.id == cc.skinLink.substr(1))
						{
							geometry.data.attachSkinData(cc.weightData);
						}
					}
				}
			}
			
			if (xml.library_materials[0])
			{
				for each(node in xml.library_materials[0].material)
				{
					var material:ColladaMaterialNode = new ColladaMaterialNode();
					material.parse(node, collector);
					materials.push(material);
				}
			}
			
			if (xml.library_effects[0])
			{
				for each(node in xml.library_effects[0].effect)
				{
					var effect:ColladaEffectNode = new ColladaEffectNode();
					effect.parse(node, collector);
					effects.push(effect);
					collector.linkObjectAnimation(effect);
				}
			}
			
		}
		
		public function getControllerByID(id:String):ColladaControllerNode
		{
			var key:String = (id.charAt(0) == "#")? id.substr(1) : id;
			for each(var controller:ColladaControllerNode in controllers)
			{
				if (controller.id == key) return controller;
			}
			return null;
		}
		
		public function getGeometryByID(id:String):ColladaGeometryNode
		{
			var key:String = (id.charAt(0) == "#")? id.substr(1) : id;
			for each(var geometry:ColladaGeometryNode in geometries)
			{
				if (geometry.id == key) return geometry;
			}
			return null;
		}
		
		public function getImageByID(id:String):ColladaImageNode
		{
			var key:String = (id.charAt(0) == "#")? id.substr(1) : id;
			for each(var image:ColladaImageNode in images)
			{
				if (image.id == key) return image;
			}
			return null;
		}
		
		public function getMaterialByID(id:String):ColladaMaterialNode
		{
			var key:String = (id.charAt(0) == "#")? id.substr(1) : id;
			for each(var material:ColladaMaterialNode in materials)
			{
				if (material.id == key) return material;
			}
			return null;
		}
		
		public function getEffectByID(id:String):ColladaEffectNode
		{
			var key:String = (id.charAt(0) == "#")? id.substr(1) : id;
			for each(var effect:ColladaEffectNode in effects)
			{
				if (effect.id == key) return effect;
			}
			return null;
		}
		
		/**
		 * ジョイントを階層構造を保ったままスキンの中にまるごと移動する。
		 */
		public function fixJointHierarchy():void 
		{
			var skins:Vector.<ColladaObjectNode> = new Vector.<ColladaObjectNode>;
			var joints:Vector.<ColladaObjectNode> = new Vector.<ColladaObjectNode>;
			
			//ルートジョイントをリストアップ
			var stock:Vector.<ColladaObjectNode> = root.childlen.concat();
			while (stock.length)
			{
				var current:ColladaObjectNode = stock.pop();
				if (current.childlen.length > 0)
				{
					stock = stock.concat(current.childlen);
				}
				if (current.type == ColladaObjectNode.TYPE_SKIN)
				{
					skins.push(current);
				}
				if (current.type == ColladaObjectNode.TYPE_JOINT)
				{
					var rootJoint:ColladaObjectNode = current.getRootJoint();
					if (joints.indexOf(rootJoint) == -1)
					{
						joints.push(rootJoint);
					}
				}
			}
			
			//ルートジョイントを全部移動する
			for each(var joint:ColladaObjectNode in joints)
			{
				for each(var skin:ColladaObjectNode in skins)
				{
					var skinMatrix:Matrix3D = skin.getWorldMatrix();
					skinMatrix.invert();
					//スキンが使うジョイント名と一致したら
					if (getControllerByID(skin.instanceLink).weightData.getJoineNames().indexOf(joint.sid) != -1)
					{
						var jointContainer:ColladaObjectNode = new ColladaObjectNode();
						jointContainer.matrix = joint.parent.matrix.clone();
						jointContainer.addChild(joint);
						
						var matrix:Matrix3D = jointContainer.getWorldMatrix();
						matrix.append(skinMatrix);
						
						jointContainer.matrix = matrix;
						skin.addChild(jointContainer);
						break;
					}
				}
			}
		}
		
	}

}